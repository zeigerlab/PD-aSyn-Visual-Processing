%% Open the Stimulus Info & GCaMP traces files
% A loop to choose multiple linked stimulus and signal files for batch
% processing
clear all
% to create infile
inputFile = uigetfile('.txt', 'choose an infile');

%read the input file and get the paths for stim and signals.
fid = fopen(inputFile,'r');
i = 1;
while ~feof(fid)
    path_sig_all{i} = fgetl(fid);    
    if ~strcmp(path_sig_all{i}(end),'\')
        path_sig_all{i} = strcat(path_sig_all{i},'\');
        [~,session{i},~] = fileparts(path_sig_all{i}(1:end-1));
    end
    i = i+1;
end
fclose(fid);
path_stim_all=path_sig_all;


for i = 1:size (path_sig_all,2)

    % check if mulitiple signal files exist
    sig_folder = sprintf('%s/%s',path_sig_all{1,i}(1:end-1));

    sig_files = dir(fullfile(sig_folder,'Image_scan_1_region_0_0_mcor*.mat'));
     if numel(sig_files) > 1
         file_sig_all {i} = uigetfile('.mat', 'choose a signal file');     
     elseif numel(sig_files) == 1
         file_sig_all {i} = 'Image_scan_1_region_0_0_mcor';
     elseif numel(sig_files) == 0
         file_sig_all {i} = 'Fall';
     end
     
     file_xml_all {i} = 'Experiment.xml';
end

disp('Choose A Location for Saving Data')
pause(0.2)
path_save = uigetdir(path_sig_all{1},'Choose A Location for Saving Data');

for itr = 1:size(file_xml_all,2)

fprintf('Analyzing %d out of %d files\n', itr, size(path_sig_all,2));

try
    load(sprintf('%s/%s',path_sig_all{itr},file_sig_all{itr}));
catch
    load(sprintf('%s/%s',path_sig_all{itr},'suite2p\','plane0\',file_sig_all{itr}));
end
p = path_sig_all {1,itr}; q = file_xml_all{1,itr};
[s]=xml2struct([p,q]);
filename=s.ThorImageExperiment.Name.Attributes.name;
depth = str2double(s.ThorImageExperiment.ZStage2.Attributes.pos)*1000;

% PFF or saline/mpi/FOV/ID
 info = path_sig_all{1,itr};
 if contains (info,'PFF')      % PFF vs Saline
     group (itr,1) = 1; % PFF == 1; saline == 0;
 else
     group (itr,1) = 0;
 end
 
 if contains (info,'Male')     % Male vs Female
     Sex (itr,1) = 0; % Male = 0, Female = 1;
 else
     Sex (itr,1) = 1;
 end

 mpi_idx = strfind (info,'mpi');   % mpi
 mpi{itr,1} = info(mpi_idx(end)-1);
 mpi{itr,1} = str2double(mpi{itr,1});

 fov {itr,1} = info (end-2:end-1);  % #FOV
 fov{itr,1} = str2double(fov{itr,1});

 ID_idx = strfind (info,'jRGECO1a');  % ID
 ID{itr,1} = info(ID_idx(end)+9:ID_idx(end)+11);
 ID{itr,1}(ID{itr,1} == '-') = [];
 ID{itr,1} = str2double(ID{itr,1});
 

if isstruct (s.ThorImageExperiment.LSM)
    frameRate = s.ThorImageExperiment.LSM.Attributes.frameRate;
    averageNum  = s.ThorImageExperiment.LSM.Attributes.averageNum;
else
   frameRate = s.ThorImageExperiment.LSM{1,1}.Attributes.frameRate;
   averageNum  = s.ThorImageExperiment.LSM{1,1}.Attributes.averageNum;  
end


framerate=str2double(frameRate)/str2double(averageNum);
%% --start DC_signal_significance
%This script was written by Daniel Cantu correlate whisker stimuli with fluorescent traces
%    obtained with 2-photon imaging of GCaMP6S. The general function of this
%script is to take a set of fluorescent signals and a single stimulus vector to which they were
%    all subjected. Then, for each individual trace, it compares the
%    trace to the stimulus and attempts to find the delay time between
%    the stimulus and the recorded signal. The signal and stimulus
%    traces are then aligned and the correlation between them is found.
%    Then, this is repeated a number of times set by the user using
%    many randomly-scrambled sets of data . The correlation of the actual signal vs the array of scrambled signals
%    are compared and the percentile rank of the actual amongst the scrambled is found.
%
%-----------Inputs------------
%stimulus_trace is a column vector of the stimulus where 0 is no stimulus and 1 is a stimulus.
%signal_traces is a matrix of the traces of your signal, which can be dF/F, Z-scores, raw F, etc.
%    The format of this is that your individual traces are each in column vectors.
%maxlagframes is the maximum number of frames your signal can lag behind the stimulus. This should definitely not be greater than
%    the period between repeated presentations of a stimulus.
%scrambles is the number of scrambles to perform and compare. 1,000 is generally a good number, but 10,000 works if you have time to spare
%    and you happen to have a rather long signal and would, thus, like to try a large number of combinations.
%threshold_value is the value of which a trace must pass in order to be
%   considered significant (e.g. 3 for Z-score-based traces, 1 for stimulus trace).
threshold_value = 3;
%threshold_frames is the number of frames which a trace must pass in order
%   to be considered significant. (6 for GCaMP6 8hz, at least 1 for stimlus trace)
framerate=str2double(frameRate)/str2double(averageNum);
threshold_frames = round(framerate*0.5); %At least 1/2 second of activity
%before_frames is the number of frames to add before the initial passing of
%   threshold, in order to find the true start of the epoch (3 for GCaMP6 8hz, 0 for stimulus trace)
before_frames = round(framerate*(3/8));
%after_frames is the number of frames to add after the final passing of threshold (8 for GCaMP6 8hz, 0 for stimulus trace)
after_frames = round(framerate*1);
%reference is where you select what is going to be used for scrambling. Enter 'signal' for scrambling the signal trace,
%    enter 'stim' for scrambling the stimulus trace. 
%         reference = 'signal';

percentile=0.01;

%Use data from EZcalcium as "signal_traces", in order of preference
if exist('Z_mod_refined')
    signal_traces=Z_mod_refined';
elseif exist('Z_mod')
    signal_traces=Z_mod';
elseif exist('ROI_list') %For DC Calcium Data
    signal_traces=DC_Calcium_Z_Fcalc(ROI_list,framerate);
elseif exist('stat') %For Suite2P Data
    signal_traces=S2P_Z_Fcalc(F,Fneu,iscell,stat,framerate);
elseif exist('sigrawCorrected') %For SpecSeg Data
    signal_traces=SpecSeg_Z_Fcalc(sigrawCorrected,framerate);
else %For EZcalcium data without ROIrefinement
    signal_traces=F_inferred';
end

%Use data from ExtractWhiskerStimStart for "stimulus_trace"
%         stimulus_trace=stim_epochs;

%-----------Outputs-----------
%signal_corr is the correlation (R) of your signals to the stimulus in a matrix.
%    These correlation numbers are bound to be low if you're comparing a square-pulse stimulus to long-tailed
%    traces such as those produces by GCaMPs. What matters more is the comparison to scrambled data.
%signal_delay are the delay times of your individual signals relative to the presentation of a stimulus in frames.
%    If you get a mix of positive and negative values, you can use the absolute value to determine the magnitude of
%    the delay. If presenting multiple stimuli that are spread apart, you should get a consistent sign in cells that
%    are considered to be actually responsive. If you are analyzing delays, don't forget to exclude cells that aren't
%    significantly correlated to the stimulus (relative to scrambles).
%signal_percentile is the percentile rankings of your signal traces relative to the scrambled traces.
%    Commonly accepted cut-offs for percentile are typically top 5% or 1% (0.05 or 0.01).
%    This is non-parametric and does not assume normality. Yay!
%    Since all traces are being compared internally to scrambled versions of themselves, differences in levels 
%    of fluorescent calcium indicator between ROIs don't impact results. Woohoo! :)


% corr_num = size(signal_traces,2) * (size(signal_traces,2)-1)/2; % calculate the pairs to be produced


[activeROI]=Determine_Active_ROIs(signal_traces,framerate);
remv = find (activeROI==0);
active_traces = signal_traces;
active_traces(:, remv)=[];         %active cells after using S2P and Determine_Active_ROIs

%matrix initialization
signal_delay=zeros(1,size(active_traces,2));
Real_corr_ROI = NaN (size(active_traces,2), size(active_traces,2));
% signal_percentile=zeros(1,size(signal_traces,2));
        

%pulling # lag frames and # scrambles from the GUI outputs
maxlagframes=round(framerate*1);
scrambles=1000;
% scram_traces_all=zeros(corr_num,scrambles,corr_num); %a matrix to store scram traces from all ROIs

    

%Added 9/2/15: subsetting signal delays for just the ROIs that are
    %"significant"
    signal_delay_sigp=NaN(1,size(active_traces,2));

  
  ROI_num = size(active_traces,2);
  R_real = zeros (ROI_num,ROI_num);
  R_shuffled = zeros (scrambles,ROI_num, ROI_num);
  pair = (ROI_num * (ROI_num-1) )* 0.5;

% make scram_traces
for ROI = 1:ROI_num
  scram_traces (:,:,ROI) =DC_epoch_scram(active_traces(:,ROI),scrambles,threshold_value,threshold_frames,before_frames,after_frames);
end


%% percentage of correlated cells with neighbouring cells 
R_ROI = NaN (scrambles + 1, ROI_num, ROI_num);
for ROI=1:ROI_num %Goes through each ROI's trace individually
 
    for comp_ROI = 1: ROI_num
               comp_trace = active_traces(:,comp_ROI);
               R_ROI_real  = xcorr(active_traces(:,ROI),comp_trace, 0,'coeff'); 
               R_ROI (1,comp_ROI,ROI) = R_ROI_real(1,1); %Use this version for MATLAB 2014a          
            

             %Compares scrambled signal traces to stimulus
                for scram=1:scrambles %does all the scrambles
                     R_ROI_shuffled  = xcorr(scram_traces(:,scram,ROI),scram_traces(:,scram,comp_ROI), 0,'coeff'); 
                     R_ROI(scram + 1,comp_ROI,ROI) = R_ROI_shuffled (1,1); 
                end
    
    end

  disp(['Percent complete: ' num2str(ROI/ROI_num*100)]);
end  

% correlated cells
for ROI = 1:ROI_num  %each ROI with all other cells
  R_shuffled_avg (:,ROI) = mean(R_ROI (:,:,ROI),2);
  signal_percentile_avg (:,ROI) = find(sort(R_shuffled_avg(:,ROI), 'descend')== R_shuffled_avg (1,ROI),1,'first')/size(R_shuffled_avg,1);
 
end



cellcount = 0;
for ii = 1:ROI_num
    if signal_percentile_avg(ii) <= percentile
             cellcount = cellcount+1;
    end
end

cellcount;
cell_correlated = cellcount/ROI_num*100
R_real_allROI = mean(R_shuffled_avg (1,:),2);
R_shuffled_allROI = mean(R_shuffled_avg (2:end,:),'all');



% pair correlated
pcount = 0;
for jj = 1:ROI_num
    for kk = 1:ROI_num
       if kk == jj
        continue
       else
         signal_percentile (1,kk,jj) = find(sort(R_ROI(:,kk,jj), 'descend')== R_ROI (1,kk,jj),1,'first')/size(R_ROI,1);
         if kk > jj && signal_percentile(1,kk,jj) <= percentile
              pcount = pcount+1;
         end
       end
    end
end
pcount;
pair_correlated = pcount/pair*100


    Mymatrix = shiftdim(R_ROI, 1);
    R_cell = num2cell(Mymatrix,[1 2]);
    R_cell = reshape(R_cell, 1, 1001);
    
    R_cell = cellfun(@replacenan, R_cell, 'UniformOutput',false);   %correlating same cell is replaced with NaN
    % row is each cell; column is for real+shuffled; first column is real and
    % the rest are shuffled.
    Rcell_avg = cellfun(@(x)mean(x,2,'omitnan'),R_cell,'UniformOutput',false);      
    Rcell_avg = cat(1,Rcell_avg{:});
    Rcell_avg = reshape(Rcell_avg,size(active_traces,2),(1 + scrambles));

    Rreal_avg = Rcell_avg(:,1);
    Rshuff_avg =mean(Rcell_avg(:,2:end),2,'omitnan');


%% percentage of correlated pairs ONLY

% R_pair = NaN (scrambles+1,pair);
% 
% ii = 1;
% for ROI = 1:ROI_num  
%    for comp_ROI = 1: ROI_num
%     if comp_ROI > ROI
%     comp_trace = signal_traces(:,comp_ROI); 
%     R_real   = xcorr(signal_traces(:,ROI),signal_traces(:,comp_ROI), 0,'coeff');         
%     R_pair (1,ii) = R_real(1,1); %Use this version for MATLAB 2014a_ for R_real trace
% 
%     for scram = 1: scrambles
%         R_shuffled   = xcorr(scram_traces(:,scram,ROI),scram_traces(:,scram,comp_ROI), 0,'coeff'); 
%         R_pair (scram+1,ii) = R_shuffled(1,1);
% 
%     end
% 
%     ii = ii + 1;
%     end
%    end
% end
% 
% % correlated pairs
% 
% pcount = 0;
% for jj = 1:pair
%        signal_percentile (1,jj) = find(sort(R_pair(:,jj), 'descend')== R_pair (1,jj),1,'first')/size(R_pair,1);
%        if signal_percentile(1,jj) <= percentile
%            pcount = pcount+1;
%        end
% 
% end
% pcount;
% pair_correlated = pcount/pair*100



 %% using peakfinder    
    trans_spont = []; peak_amp = [];
    duration = size (active_traces,1)./framerate; %in seconds
    duration = duration/60; %in min

for ii = 1:size (active_traces,2)
    [amp_temp, idx_temp] = findpeaks (active_traces (:,ii), 'MinPeakDistance',4, 'MinPeakHeight',4);    
    peak_amp (ii,1) =  mean(amp_temp); %calcium transients
    trans_spont (ii,1) = length(idx_temp)/duration;   %frequency of calcium transients (per min)
    AUC_spont(ii,1)  = trapz (active_traces (:,ii))./framerate;  %AUC* seconds
end
  
   peak_amp_avg = mean (peak_amp,'omitnan');
   trans_spont_avg = mean (trans_spont,'omitnan');
   AUC_spont ( AUC_spont  < 0 ) = 0;  
   AUC_spont_avg = mean (AUC_spont,'omitnan');

   trans_spont_a = trans_spont( trans_spont <= 10 );
   trans_spont_b = trans_spont( trans_spont > 10 & trans_spont <= 20);
   trans_spont_c = trans_spont( trans_spont > 20 & trans_spont <= 30);
   trans_spont_d = trans_spont( trans_spont > 30 & trans_spont <= 40);
   trans_spont_e = trans_spont( trans_spont > 40);

   trans_spont_count = [length(trans_spont_a) length(trans_spont_b) length(trans_spont_c) length(trans_spont_d) length(trans_spont_e)];
   trans_spont_prop = trans_spont_count./size(active_traces,1)*100; 
 
  
%    for ii = 1: size (Z_mod_refined,1)
%        for jj = 1: size (Z_mod_refined,1)
%            realc_all (ii,jj) = xcorr(Z_mod_refined (ii,:),Z_mod_refined (jj,:), 0,'coeff');
%            jj = jj + 1;
%        end
%    end
% 
% realc = mean (realc_all,'all');




%Make a structure with a field for each variable
EvokedData (itr) =struct('FileName',session{itr},...  
    'ID', ID{itr},...
    'mpi',mpi{itr},...
    'FOV',fov{itr},...
    'Group',group (itr),...
    'Sex', Sex(itr),...
    'framerate',framerate, ...
    'signal_traces', signal_traces, ...
    'activeROI', activeROI,...
    'total_ncells', size(active_traces,2),...
    'pair_correlated', pair_correlated, ...
    'cell_correlated', cell_correlated, ...
    'peak_amp_avg', peak_amp_avg,...    
    'trans_spont_avg', trans_spont_avg, ...
    'AUC_spont_avg', AUC_spont_avg, ...
    'trans_spont_prop', trans_spont_prop,...
    'total_npairs', pair,...
    'correlated_npairs', pcount,...
    'depth', depth,...    
    'peak_amp', peak_amp, ...
    'trans_spont', trans_spont,...
    'AUC_spont',AUC_spont,...
    'Rreal_avg',Rreal_avg,...
    'Rshuff_avg',Rshuff_avg);
 

%     'signal_traces',signal_traces, 'signal_percentile',signal_percentile,

cd(path_stim_all{itr})
save(sprintf('%s_Analyzed_%s.mat',filename,datetime('now','Format','ddMMMyyyy_hhmm')))

if itr == size(file_sig_all,2)
    if exist('StimEvokedResponseData')==0 %if it doesn't exist, create it
       StimEvokedResponseData=EvokedData;
    else
       StimEvokedResponseData =[StimEvokedResponseData,EvokedData]; %add data to data from the other files
    end


cd(path_save)
save(sprintf('Batch_Analyzed_%s.mat',datetime('now','Format','ddMMMyyyy_hhmm')),'StimEvokedResponseData','-v7.3') 
end

clearvars AUC_spont
end



%% Internal Functions

%Calculate modified Z-scores from DC_Calcium selected ROIs
function [Z_F]=DC_Calcium_Z_Fcalc(ROI_list,framerate)
baselineframes=round(10*framerate);

F=zeros(size(ROI_list,2),size(ROI_list(1,1).fmean,1));
    for i=1:size(ROI_list,2)
        F(i,:)=(ROI_list(1,i).fmean);
    end
%transpose the matrix to get old format
F=F';
Fsize=size(F);

zerocount=zeros(1,Fsize(2));
for q=1:Fsize(2)
    for qq=1:Fsize(1)
        if F(qq,q)==0;
            zerocount(q)=zerocount(q)+1;
            F(qq,q)=NaN;
        end  
    end
    if zerocount(q)>(0.05*Fsize(1))
        F(:,q)=NaN;
    end
end

columnmins=zeros(1,Fsize(2));
for p=1:Fsize(2)
    columnmins(p) = min(F(:,p));
end

for q=1:Fsize(2)
    for qq=1:Fsize(1)
        if isnan(F(qq,q))
            F(qq,q)=columnmins(q);
        end     
    end
end


%-----------Calculate Baseline F for each ROI (all experiment
%types)------------------------
basecalc=zeros(1,Fsize(1)-baselineframes+1);
Fbaseline=zeros(1,Fsize(2));
mindex=zeros(1,Fsize(2));
%Fbaseline=median(F);
for j=1:Fsize(2)  %calculate baseline by using median
    for i=1:Fsize(1)-baselineframes+1 %find 10 seconds of baseline. RECALC based on framerate
        basecalc(i)=std(F(i:i+baselineframes-1,j)); %checks STD for all values

    end
    [~,mindex(j)]=min(basecalc); %calculate the position of lowest deviation for baseline
    Fbaseline(j)=mean(F(mindex(j):mindex(j)+baselineframes-1,j));
    Fbaselinedev(j)=std(F(mindex(j):mindex(j)+baselineframes-1,j)); %Added on 7/25/14
    disp(['Calculating Baseline: ', (num2str(100*j/Fsize(2))), '%']);
end

%----------------End Calculate Baseline F--------------------------------

%use standard deviation for the 10 quietest seconds and
%calculate Z_F for all data where Z_F = (F(t) - mean of baseline
%period)/std(baseline period).  Threshold is now set to a [modified]
%Z-score of 3, with significance (red frames) set to 6 consecutive frames
%above threshold.

%--------------Calculate Z_F for each ROI (all experiment
%types)-------------------------------
Z_F=zeros(Fsize(1),Fsize(2)); %Renamed "Z_F" from previous "dF" (7/25/14)
for i=1:Fsize(1)
    for j=1:Fsize(2)
        if F(i,j)==0   
            Z_F(i,j)=0; %set to 0 if no data available; but shouldn't be any more 0's at this point 
        else
%             dF(i,j)=100*(F(i,j)-Fbaseline(j))/(Fbaseline(j));
            Z_F(i,j)=(F(i,j)-Fbaseline(j))/(Fbaselinedev(j)); %New on 7/25/14
        end
    end
end

%----------End Calculate Z_F for each ROI-------------------------------
end


%Calculate modified Z-scores from SpecSeg selected ROIs
function [Z_F]=SpecSeg_Z_Fcalc(sigrawCorrected,framerate)
baselineframes=round(10*framerate);

F=sigrawCorrected;
Fsize=size(F);

zerocount=zeros(1,Fsize(2));
for q=1:Fsize(2)
    for qq=1:Fsize(1)
        if F(qq,q)==0;
            zerocount(q)=zerocount(q)+1;
            F(qq,q)=NaN;
        end  
    end
    if zerocount(q)>(0.05*Fsize(1))
        F(:,q)=NaN;
    end
end

columnmins=zeros(1,Fsize(2));
for p=1:Fsize(2)
    columnmins(p) = min(F(:,p));
end

for q=1:Fsize(2)
    for qq=1:Fsize(1)
        if isnan(F(qq,q))
            F(qq,q)=columnmins(q);
        end     
    end
end


%-----------Calculate Baseline F for each ROI (all experiment
%types)------------------------
basecalc=zeros(1,Fsize(1)-baselineframes+1);
Fbaseline=zeros(1,Fsize(2));
mindex=zeros(1,Fsize(2));
%Fbaseline=median(F);
for j=1:Fsize(2)  %calculate baseline by using median
    for i=1:Fsize(1)-baselineframes+1 %find 10 seconds of baseline. RECALC based on framerate
        basecalc(i)=std(F(i:i+baselineframes-1,j)); %checks STD for all values

    end
    [~,mindex(j)]=min(basecalc); %calculate the position of lowest deviation for baseline
    Fbaseline(j)=mean(F(mindex(j):mindex(j)+baselineframes-1,j));
    Fbaselinedev(j)=std(F(mindex(j):mindex(j)+baselineframes-1,j)); %Added on 7/25/14
    disp(['Calculating Baseline: ', (num2str(100*j/Fsize(2))), '%']);
end

%----------------End Calculate Baseline F--------------------------------

%use standard deviation for the 10 quietest seconds and
%calculate Z_F for all data where Z_F = (F(t) - mean of baseline
%period)/std(baseline period).  Threshold is now set to a [modified]
%Z-score of 3, with significance (red frames) set to 6 consecutive frames
%above threshold.

%--------------Calculate Z_F for each ROI (all experiment
%types)-------------------------------
Z_F=zeros(Fsize(1),Fsize(2)); %Renamed "Z_F" from previous "dF" (7/25/14)
for i=1:Fsize(1)
    for j=1:Fsize(2)
        if F(i,j)==0   
            Z_F(i,j)=0; %set to 0 if no data available; but shouldn't be any more 0's at this point 
        else
%             dF(i,j)=100*(F(i,j)-Fbaseline(j))/(Fbaseline(j));
            Z_F(i,j)=(F(i,j)-Fbaseline(j))/(Fbaselinedev(j)); %New on 7/25/14
        end
    end
end

%----------End Calculate Z_F for each ROI-------------------------------

end



%Calculate modified Z-scores from Suite2P selected ROIs
function [Z_F]=S2P_Z_Fcalc(F,Fneu,iscell,stat,framerate)
baselineframes=round(10*framerate);
keepidx=iscell(:,1);
mergedidx=cell2mat(cellfun(@(s)s.inmerge,stat,'uni',0));
keepidx(mergedidx>0)=0;
F_org=F;
F_refined=F(keepidx==1,:);
Fneu_refined=Fneu(keepidx==1,:);
F_refined_sub=F_refined-0.7*Fneu_refined;

%transpose the matrix to get old format
F=F_refined_sub';
Fsize=size(F);

zerocount=zeros(1,Fsize(2));
for q=1:Fsize(2)
    for qq=1:Fsize(1)
        if F(qq,q)==0
            zerocount(q)=zerocount(q)+1;
            F(qq,q)=NaN;
        end  
    end
    if zerocount(q)>(0.05*Fsize(1))
        F(:,q)=NaN;
    end
end

columnmins=zeros(1,Fsize(2));
for p=1:Fsize(2)
    columnmins(p) = min(F(:,p));
end

for q=1:Fsize(2)
    for qq=1:Fsize(1)
        if isnan(F(qq,q))
            F(qq,q)=columnmins(q);
        end     
    end
end


%-----------Calculate Baseline F for each ROI (all experiment
%types)------------------------
basecalc=zeros(1,Fsize(1)-baselineframes+1);
Fbaseline=zeros(1,Fsize(2));
mindex=zeros(1,Fsize(2));
%Fbaseline=median(F);
for j=1:Fsize(2)  %calculate baseline by using median
    for i=1:Fsize(1)-baselineframes+1 %find 10 seconds of baseline. RECALC based on framerate
        basecalc(i)=std(F(i:i+baselineframes-1,j)); %checks STD for all values

    end
    [~,mindex(j)]=min(basecalc); %calculate the position of lowest deviation for baseline
    Fbaseline(j)=mean(F(mindex(j):mindex(j)+baselineframes-1,j));
    Fbaselinedev(j)=std(F(mindex(j):mindex(j)+baselineframes-1,j)); %Added on 7/25/14
    disp(['Calculating Baseline: ', (num2str(100*j/Fsize(2))), '%']);
end

%----------------End Calculate Baseline F--------------------------------

%use standard deviation for the 10 quietest seconds and
%calculate Z_F for all data where Z_F = (F(t) - mean of baseline
%period)/std(baseline period).  Threshold is now set to a [modified]
%Z-score of 3, with significance (red frames) set to 6 consecutive frames
%above threshold.

%--------------Calculate Z_F for each ROI (all experiment
%types)-------------------------------
Z_F=zeros(Fsize(1),Fsize(2)); %Renamed "Z_F" from previous "dF" (7/25/14)
for i=1:Fsize(1)
    for j=1:Fsize(2)
        if F(i,j)==0   
            Z_F(i,j)=0; %set to 0 if no data available; but shouldn't be any more 0's at this point 
        else
%             dF(i,j)=100*(F(i,j)-Fbaseline(j))/(Fbaseline(j));
            Z_F(i,j)=(F(i,j)-Fbaseline(j))/(Fbaselinedev(j)); %New on 7/25/14
        end
    end
end

%----------End Calculate Z_F for each ROI-------------------------------
end

%% Determine if a cell is active or not
function [activeROI]=Determine_Active_ROIs(signal_traces,framerate)

sigdF=3; %New on 7/25/14; sets threshold for significance as Z_F of 3
sigframes=zeros(size(signal_traces,1),size(signal_traces,2));
activeframes=zeros(size(signal_traces,1),size(signal_traces,2));
activeROI=zeros(1,size(signal_traces,2)); 
sigframenum=round(0.5*framerate);  %Set this on 3/19/15.       
    
for j=1:size(signal_traces,2) %Going col by col (ROI by ROI)
    for i=1:size(signal_traces,1) %Going row by row (frame by frame)
        if signal_traces(i,j)>sigdF %if Z_F>3, set above in sigdF=sigdF+3
            sigframes(i,j)=1; %1 means that frame in that ROI is above threshold
        end
    end
end

for j=1:size(signal_traces,2) %Going col by col (ROI by ROI)
    for i=1:size(signal_traces,1) %Going row by row (frame by frame)
        sigcount=0;
        if sigframes(i,j)==1 %For every instance where sigframe=1, 
            sigcount=sigcount+1; 
            %If the currently indexed frame + k (where k is 1-5 for
            %sigframenum=6) is less than the total # of frames, AND current
            %frame + k is an active frame, then add 1 to sigcount
            for k=1:sigframenum-1
                if ((i+k <= size(signal_traces,1)) && (sigframes(i+k,j)==1))
                    sigcount=sigcount+1;
                end
            end
            if sigcount==sigframenum
                activeframes(i:i+sigframenum-1,j)=1; 
                %if you have sigframenum of consecutive active frames, then
                %set those frames to 1 in the activeframes matrix (same
                %dimensions as Z_F)
            end
        end
    end
end

sumactive=sum(activeframes,1); %creates row vector containing, for each ROI (column),
%the number of instances of sigframenum consecutive active frames
%(previously denoted by activeframes=1).
for j=1:size(signal_traces,2) 
    if sumactive(j)>=1
        activeROI(1,j)=1; %populating row vector wherein each value will represent 
        %whether that ROI has sigframenum consecutive active frames or not
    end
end
end


function [matrix] = replacenan(matrix)
       matrix(eye(size(matrix))==1) = NaN;   

end




