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




for i = 1:size (path_stim_all,2)
    % Get the stim data
    file_stim_all {i} = strcat(session {i},'_StimInfo');

    % check if mulitiple signal files exist
    sig_folder = sprintf('%s/%s',path_stim_all{1,i}(1:end-1));
    sig_files = dir(fullfile(sig_folder,'Image_scan_1_region_0_0_mcor*.mat'));
     if numel(sig_files) > 1
         file_sig_all {i} = uigetfile('.mat', 'choose a signal file');
     elseif numel(sig_files) == 1
         file_sig_all {i} = 'Image_scan_1_region_0_0_mcor';
     elseif numel(sig_files) == 0
         file_sig_all {i} = 'Fall';   
     end
end

disp('Choose A Location for Saving Data')
pause(0.2)
path_save = uigetdir(path_stim_all{1},'Choose A Location for Saving Data');

for itr = 1:size(file_stim_all,2)
     fprintf('Analyzing %d out of %d files\n', itr, size(path_sig_all,2));

     try
     load(sprintf('%s/%s',path_sig_all{itr},file_sig_all{itr}));
     catch
     load(sprintf('%s/%s',path_sig_all{itr},'suite2p\','plane0\',file_sig_all{itr}));
     end
     load(sprintf('%s/%s',path_stim_all{itr},file_stim_all{itr}));  
     filename=s.ThorImageExperiment.Name.Attributes.name;
     depth = str2double(s.ThorImageExperiment.ZStage2.Attributes.pos)*1000;

     % PFF or saline/mpi/FOV/ID
        info = path_sig_all{1,itr};
     if contains (info,'PFF')
         group (itr,1) = 1; % PFF == 1; saline == 0;
     else
         group (itr,1) = 0;
     end
     
     if contains (info,'Male')
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
        reference = 'active';

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
        tic

        %Use data from ExtractWhiskerStimStart for "stimulus_trace"
        stimulus_trace=stim_epochs;    


        [activeROI]=Determine_Active_ROIs(signal_traces,framerate);
        remv = find (activeROI==0);
        active_traces = signal_traces;
        active_traces(:, remv)=[];         %active cells after using S2P and Determine_Active_ROIs


        %matrix initialization
        signal_delay=zeros(1,size(active_traces,2));
        signal_corr=zeros(1,size(active_traces,2)); 
        signal_percentile=zeros(1,size(active_traces,2));

        %pulling # lag frames and # scrambles from the GUI outputs
        maxlagframes=round(framerate*1);
        scrambles=10000;
%       scram_traces_all=zeros(size(active_traces,1),scrambles,size(active_traces,2)); %a matrix to store scram traces from all ROIs

        pcount = 0;
            %Added 9/2/15: subsetting signal delays for just the ROIs that are
            %"significant"
            signal_delay_sigp=NaN(1,size(active_traces,2));

        for ROI=1:size(active_traces,2) %Goes through each ROI's trace individually
            [Xa,Ya,signal_delay(ROI)]=alignsignals(stimulus_trace,active_traces(:,ROI),maxlagframes); %Aligns signal and stimulus, finds delay time
            R=corrcoef(Xa(1:size(active_traces,1)),Ya(1:size(active_traces,1))); %finds correlation of aligned traces
            if length(R)==1
                signal_corr(ROI)=R(1,1); %Use this version for MATLAB 2014a
            else
                signal_corr(ROI)=R(2,1); %Use this version for older versions of MATLAB
            end 
            scram_corrs=zeros(1,scrambles+1); %resets scramble correlations to zeros, leaves a space at the end for comparing your trace
            if strcmp(reference,'active')==1 
                 %Performs epoch-based scrambling of Signal trace
                scram_traces=DC_epoch_scram(active_traces(:,ROI),scrambles,threshold_value,threshold_frames,before_frames,after_frames);
%                 scram_traces_all(:,:,ROI)=scram_traces;
                %Compares scrambled signal traces to stimulus
                for scram=1:scrambles %does all the scrambles
                    [Xa,Ya,~]=alignsignals(stimulus_trace,scram_traces(:,scram),maxlagframes); %aligns by same parameters as original data
                    R=corrcoef(Xa(1:size(active_traces,1)),Ya(1:size(active_traces,1))); %correlation of the scrambles are stored
                    if length(R)==1
                        scram_corrs(scram)=R(1,1); 
                    else
                        scram_corrs(scram)=R(2,1);
                    end
                end
            elseif strcmp(reference,'stim')==1
                %Performs epoch-based scrambling of Stimulus trace
                scram_stim=DC_epoch_scram(stimulus_trace,scrambles,threshold_value,threshold_frames,before_frames,after_frames);
                %Compares scrambled stimuli traces to raw signal trace
                for scram=1:scrambles 
                    [Xa,Ya,~]=alignsignals(scram_stim(:,scram),active_traces(:,ROI),maxlagframes); %aligns by same parameters as original data
                    R=corrcoef(Xa(1:size(active_traces,1)),Ya(1:size(active_traces,1))); %correlation of the scrambles are stored
                    if length(R)==1
                        scram_corrs(scram)=R(1,1); 
                    else
                        scram_corrs(scram)=R(2,1);
                    end
                end
            else
                error('Error: must enter a valid string for input variable Reference!') %Error if incorrect string entered as input
            end
            scram_corrs(scrambles+1)=signal_corr(ROI); %throws your ROI of interest's correlation into the list and then finds its rank
            signal_percentile(ROI)=find(sort(scram_corrs,'descend')==signal_corr(ROI),1,'first')/size(scram_corrs,2); %percentile is calculated
            %    lower value for signal_percentile are more significant.
            disp(['Percent complete: ' num2str(ROI/size(active_traces,2)*100)]);

            %Added 9/2/15
            if signal_percentile(ROI)<=percentile
                pcount = pcount+1;
                signal_delay_sigp(ROI)=signal_delay(ROI);
            else
                signal_delay_sigp(ROI)=1000;
            end

        end 

    signal_percentile
    pcount
    percent_responsive=pcount/size(active_traces,2)*100


    % select only ROIs which are only responsive

allROI_signal = active_traces';
j = 1;
for i = 1: size(signal_percentile,2)
    if signal_percentile (i) <= percentile
        lockedROI (j,:) = allROI_signal (i,:);
        j = j + 1;
    end
end

% Set the stimuli duration consistent. 
% n = min(stimends-stimstarts);
stimends = stimstarts+ 10;  %this works only if images were acquired with averaging of 3.

%Find area under the curve (AUC) of z_mod of responsive ROIs for each
%direction to get neuronal response to each direction stimulus.

stimends_mod = round (stimends + 0.5.*framerate);  % to add 2 extra seconds after the stimulus ends

for j = 1 : size (lockedROI, 1)
    counter = 1;
    for i = 1 : 8: 32
    AUC_zeroA (j,counter)  = trapz (stimstarts (i) : stimends_mod (i), lockedROI (j, stimstarts (i) : stimends_mod (i)));             %zero degree  
    AUC_zeroB (j,counter)  = trapz (stimstarts (i+3) : stimends_mod (i+3), lockedROI (j, stimstarts (i+3) : stimends_mod (i+3)));     %45 degree
    AUC_zeroC (j,counter)  = trapz (stimstarts (i+6) : stimends_mod (i+6), lockedROI (j, stimstarts (i+6) : stimends_mod (i+6)));     %90 degree
    AUC_zeroD (j,counter)  = trapz (stimstarts (i+1) : stimends_mod (i+1), lockedROI (j, stimstarts (i+1) : stimends_mod (i+1)));     %135 degree
    AUC_zeroE (j,counter)  = trapz (stimstarts (i+4) : stimends_mod (i+4), lockedROI (j, stimstarts (i+4) : stimends_mod (i+4)));     %180 degree
    AUC_zeroF (j,counter)  = trapz (stimstarts (i+7) : stimends_mod (i+7), lockedROI (j, stimstarts (i+7) : stimends_mod (i+7)));     %225 degree
    AUC_zeroG (j,counter)  = trapz (stimstarts (i+2) : stimends_mod (i+2), lockedROI (j, stimstarts (i+2) : stimends_mod (i+2)));     %270 degree   
    AUC_zeroH (j,counter)  = trapz (stimstarts (i+5) : stimends_mod (i+5), lockedROI (j, stimstarts (i+5) : stimends_mod (i+5)));     %315 degree       
    counter = counter + 1; 
    end 
end


% set negative AUC of Z_mod to zero
    AUC_zeroA (AUC_zeroA < 0 ) = 0;
    AUC_zeroB (AUC_zeroB < 0 ) = 0;
    AUC_zeroC (AUC_zeroC < 0 ) = 0;
    AUC_zeroD (AUC_zeroD < 0 ) = 0;
    AUC_zeroE (AUC_zeroE < 0 ) = 0;
    AUC_zeroF (AUC_zeroF < 0 ) = 0;
    AUC_zeroG (AUC_zeroG < 0 ) = 0;
    AUC_zeroH (AUC_zeroH < 0 ) = 0;

% %AUC per seconds
%     AUC_zeroA = AUC_zeroA./framerate;
%     AUC_zeroB = AUC_zeroA./framerate;
%     AUC_zeroC = AUC_zeroA./framerate;
%     AUC_zeroD = AUC_zeroA./framerate;
%     AUC_zeroE = AUC_zeroA./framerate;
%     AUC_zeroF = AUC_zeroA./framerate;
%     AUC_zeroG = AUC_zeroA./framerate;
%     AUC_zeroH = AUC_zeroA./framerate;

%Find AUC of z_mod of responsive ROIs for each orientation.

%  __ orientation (East)
AUC_E = sum ([AUC_zeroA AUC_zeroE],2);

%  |  orientation (North)
AUC_N = sum ([AUC_zeroC AUC_zeroG],2);

%  /  orientation (North East)
AUC_NE = sum ([AUC_zeroD AUC_zeroH],2);

%  \   orientation (North West)
AUC_NW = sum ([AUC_zeroB AUC_zeroF],2);


%find the preferred orientations for each responsive ROI
% calculate orientation selectivity index 
% (OSI was defined as (Rpref - Rortho)/(Rpref + Rortho), where Rpref, the response in the preferred orientation, was the
% response with the largest magnitude. Rpref was determined as the mean of the integrals of the calcium transients 
% for the two corresponding opposite directions. Rortho was similarly calculated as the response evoked by the 
% orthogonal orientation (Rochefort et al., 2011; DOI 10.1016/j.neuron.2011.06.013)).

orientation = [];
compare_ori = [AUC_E AUC_N AUC_NE AUC_NW];
[~, orientation] = max (compare_ori,[],2);
for i = 1: size (lockedROI, 1)
    switch orientation (i,:)
        case {1,2}  % preferred/ orthogonal pair is North | &  East __
            OSI (i,:) = abs ((AUC_E(i) - AUC_N(i))/(AUC_E(i) + AUC_N(i)));
        case {3,4}  % preferred/ orthogonal pair is Northeast / & Northwest \
            OSI (i,:) = abs ((AUC_NE(i) - AUC_NW(i))/(AUC_NE(i) + AUC_NW(i)));
    end
end


%DSI was defined as (Rpref - Ropp)/(Rpref + Ropp), where Ropp is the
%response in the direction opposite to the preferred direction

% average over 4 trials for each direction
 AUC_zeroA_avg = mean (AUC_zeroA,2);
 AUC_zeroB_avg = mean (AUC_zeroB,2);
 AUC_zeroC_avg = mean (AUC_zeroC,2);
 AUC_zeroD_avg = mean (AUC_zeroD,2);
 AUC_zeroE_avg = mean (AUC_zeroE,2);
 AUC_zeroF_avg = mean (AUC_zeroF,2);
 AUC_zeroG_avg = mean (AUC_zeroG,2);
 AUC_zeroH_avg = mean (AUC_zeroH,2);

direction = [];
compare_dir  = [AUC_zeroA_avg AUC_zeroB_avg AUC_zeroC_avg AUC_zeroD_avg AUC_zeroE_avg AUC_zeroF_avg AUC_zeroG_avg AUC_zeroH_avg];
[~, direction] = max (compare_dir,[],2);
for i = 1: size (lockedROI, 1)
    switch direction (i,:)
        case {1,5}  % preferred/ opp pair is 0 and 180
            DSI (i,:) = abs ((AUC_zeroA_avg(i) - AUC_zeroE_avg(i))/(AUC_zeroA_avg(i) + AUC_zeroE_avg(i)));
        case {2,6}  % preferred/ opp pair is 45 and 225
            DSI (i,:) = abs ((AUC_zeroB_avg(i) - AUC_zeroF_avg(i))/(AUC_zeroB_avg(i) + AUC_zeroF_avg(i)));
        case {3,7}  % preferred/ opp pair is 90 and 270
            DSI (i,:) = abs ((AUC_zeroC_avg(i) - AUC_zeroG_avg(i))/(AUC_zeroC_avg(i) + AUC_zeroG_avg(i)));
        otherwise  % preferred/ opp pair is 135 and 315
            DSI (i,:) = abs ((AUC_zeroD_avg(i) - AUC_zeroH_avg(i))/(AUC_zeroD_avg(i) + AUC_zeroH_avg(i)));
    end
end

% OSI proportion
OSI_a = OSI( OSI <= 0.2 );
OSI_b = OSI( OSI > 0.2 & OSI <= 0.4);
OSI_c = OSI( OSI > 0.4 & OSI <= 0.6);
OSI_d = OSI( OSI > 0.6 & OSI <= 0.8);
OSI_e = OSI( OSI > 0.8);  

OSI_count = [length( OSI_a) length( OSI_b) length( OSI_c) length( OSI_d) length( OSI_e)];
OSI_prop = OSI_count./size(lockedROI,1)*100;


% DSI proportion
DSI_a = DSI( DSI <= 0.2 );
DSI_b =  DSI( DSI > 0.2 & DSI <= 0.4);
DSI_c = DSI( DSI > 0.4 & DSI <= 0.6);
DSI_d = DSI(DSI > 0.6 & DSI <= 0.8);
DSI_e = DSI( DSI > 0.8);

DSI_count = [length(DSI_a) length(DSI_b) length(DSI_c) length(DSI_d) length(DSI_e)];
DSI_prop = DSI_count ./size(lockedROI,1)*100;


OSI_highly = length(find(OSI > 0.5))/size(lockedROI,1)*100; %percentage of cells with OSI > 0.5
DSI_highly = length(find(DSI > 0.5))/size(lockedROI,1)*100; %percentage of cells with DSI > 0.5
OSI_broadly = length(find(OSI < 0.5 | OSI == 0.5))/size(lockedROI,1)*100; %percentage of cells with OSI <= 0.5
DSI_broadly = length(find(DSI < 0.5 | OSI == 0.5))/size(lockedROI,1)*100; %percentage of cells with DSI <= 0.5
ncells_OSIhi = length(find(OSI > 0.5));
ncells_DSIhi = length(find(DSI > 0.5));


% to determine the start of each direction in each trial
trial_stimstarts = cell (1,4); 
 j = [1,9,17,25];
for i = 1: numel(j)  % for 4 trials  
    trial_stimstarts{1,i} = stimstarts (j(i):j(i)+7);   
end  

% to determine the end of each direction in each trial
trial_stimends = cell (1,4); 
 j = [1,9,17,25];
for i = 1: numel(j)  % for 4 trials  
    trial_stimends_mod{1,i} = stimends_mod (j(i):j(i)+7);  
end
       

% Organize calcium signals for each trial, orientation of all responsive
% cells
%in 2D, row is trial and column is orientation. 
trial_trace = {}; counter = 1;
for k = 1:size (OSI,1)  % # responsive cells
%     if OSI (k) > 0.5
        for i = 1: 4   % #trials    
                for j = 1:8   % #orientations
%                 trial_trace {i,j,counter} = lockedROI (k,trial_stimstarts{i}(j): trial_stimends_mod {i}(j)); 
                trial_trace {i,j,k} = lockedROI (k,trial_stimstarts{i}(j): trial_stimends_mod {i}(j));  
                end
        end
%  counter = counter + 1;
%     end
end


% find the average signals over 4 trials
for i = 1: size (trial_trace, 3) 
    for j = 1 : 8
    frames_stimuli  = size (trial_trace{1,j},2);
    trial_trace_avg (:,:,i) = mat2tiles (mean (cell2mat(trial_trace (:,:,i)),1) ,[1, frames_stimuli ]);
    end
end 


% Reset the trial start and end time to zero 
trial_stimstarts_reset = cell2mat(trial_stimstarts) - min(cell2mat(trial_stimstarts));
trial_stimstarts_reset = trial_stimstarts_reset';
trial_stimends_mod_reset = cell2mat(trial_stimends_mod) - min(cell2mat(trial_stimstarts));
trial_stimends_mod_reset = trial_stimends_mod_reset';


%% Tuning curve

%calculate tuning curve based on AUC of 3s from the stimulus start in each
%direction
% curvecalc = [sum(AUC_zeroA,2) sum(AUC_zeroB,2) sum(AUC_zeroC,2)  sum(AUC_zeroD,2),...
%             sum(AUC_zeroE,2)  sum(AUC_zeroF,2) sum(AUC_zeroG,2) sum(AUC_zeroH,2)];
% 
% tunecurve = curvecalc./sum(curvecalc,2)*100;
% orientcurve = [];
% for i = 1:4
%     orientcurve (:,i) = tunecurve(:,i)+tunecurve(:,i + 4);
% end

orientcurve = [AUC_E AUC_NW AUC_N AUC_NE]; 
orientcurve = orientcurve./sum(orientcurve,2)*100;

[OSI_new,tunewidth,prefor] = DCLWAG_OSI(orientcurve); 
tunewidth_mean = mean (tunewidth (OSI > 0.5));    % mean tune width with OSI > 0.5





 %%
   
%Make a structure with a field for each variable
EvokedData (itr) =struct('FileName',file_stim_all{itr},...
    'ID', ID{itr},...
    'mpi',mpi{itr},...
    'FOV',fov{itr},...
    'Group',group (itr),...
    'Sex', Sex(itr),...
    'signal_traces',signal_traces,...
    'activeROI', activeROI,...
    'stim_epochs',stim_epochs,...
    'signal_percentile',signal_percentile,...
    'stimstarts', stimstarts,...
    'stimends', stimends,...                     
    'framerate',framerate, ...
    'tunewidth', tunewidth, ...
    'OSI_new', OSI_new, 'OSI', OSI, 'DSI', DSI, 'prefor',prefor, ...
    'percent_responsive',percent_responsive,... 
    'OSI_prop',OSI_prop,  'DSI_prop',DSI_prop,...
    'OSI_highly', OSI_highly, 'OSI_broadly', OSI_broadly, ...
    'DSI_highly', DSI_highly, 'DSI_broadly', DSI_broadly, ...
    'mean_tuning_width_above', tunewidth_mean,...
    'total_ncells', size(active_traces,2),...
    'active_cells', pcount,... 
    'ncells_OSIhi',ncells_OSIhi,...
    'ncells_DSIhi', ncells_DSIhi,...
    'depth', depth);
        
                
cd(path_stim_all{itr})
save(sprintf('%s_Analyzed_%s.mat',filename,datetime('now','Format','ddMMMyyyy_hhmm')))

if itr == size(file_stim_all,2)
    if exist('StimEvokedResponseData')==0 %if it doesn't exist, create it
       StimEvokedResponseData=EvokedData;
    else
       StimEvokedResponseData =[StimEvokedResponseData,EvokedData]; %add data to data from the other files
    end
cd(path_save)
save(sprintf('Batch_Analyzed_%s.mat',datetime('now','Format','ddMMMyyyy_hhmm')),'StimEvokedResponseData') 
end

clearvars -except path_sig_all file_sig_all path_stim_all file_stim_all path_save StimEvokedResponseData EvokedData

end


%% function for fitting into gaussian functions (from Goel)

function [OSI,tunewidth,tunepref] = DCLWAG_OSI(curve)
OSI=zeros(size(curve,1),1);
tunewidth=zeros(size(curve,1),1);
tunepref=NaN(size(curve,1),1);
for i=1:size(curve,1) %for every ROI
    %Calculate preferred orientation based on dF values of a tuning curve equal
    %to the mean of the responses for each orientation
    orient=[-90 -45 0 45 90]; %angles of orientation relative to preferred
    %fits a Gaussian around point 0
    prefdF=[0 0 0 0 0];
    [~,I]=max(curve(i,:));
    calc_pref_or=I;
    prefdF(3)=curve(i,I); %put max value in center
    %fills in other values, repeat edges
    if I==4
        I=1;
    else
        I=I+1;
    end
    prefdF(4)=curve(i,I); %fills 4th value with next number
    if I==4
        I=1;
    else
        I=I+1;
    end
    prefdF(5)=curve(i,I); %fills 1st and 5th with same
    prefdF(1)=curve(i,I);
    if I==4
        I=1;
    else
        I=I+1;
    end
    prefdF(2)=curve(i,I); %second value

    % fitting using ezfit (ezyfit toolbox required)
    fit=ezfit(orient,prefdF,'y(x) = a*exp(-((x-x_0)^2)/(2*sigma^2)); x_0=0'); %showfit(fit) to plot the fitted curve
    sigma=fit.m(2);
    if abs(sigma)<15 %min sigma is 15 due to resolution limited to 45 degrees between stimuli (Ackerboom 2012)
        fit=ezfit(orient,prefdF,'y(x) = a*exp(-((x-x_0)^2)/(2*sigma^2)); sigma=15; x_0=0');
        sigma=fit.m(2);
    end
    a=fit.m(1);
    x_0=fit.m(3);


    %fitting using fit
%     ft = fittype( 'a*exp(-((x-x_0)^2)/(2*sigma^2))', 'independent', 'x', 'dependent', 'y' );
%     opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
%     opts.Lower = [-Inf 0 -Inf];
%     [fitresult, ~] = fit( orient', prefdF', ft, opts );
%     sigma=fitresult.sigma;
%       if abs(sigma)<15  %min sigma is 15 due to resolution limited to 45 degrees between stimuli (Ackerboom 2012)
%         ft = fittype( 'a*exp(-((x-x_0)^2)/(2*sigma^2))', 'independent', 'x', 'dependent', 'y' );
%         opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
%         opts.Lower = [-Inf 0 15]; 
%         [fitresult, ~] = fit( orient', dF', ft, opts )
%         sigma=fitresult.sigma;
%       end
%     a=fitresult.a;
%     x_0=fitresult.x_0;



    Rpref=a*exp(-((0-x_0)^2)/(2*sigma^2)); %amplitude at 0
    Rortho=a*exp(-((90-x_0)^2)/(2*sigma^2)); %amplitude at 90
    %R are the response amplitudes of the fitted gaussians to the orientation
    %tuning curve
    OSI(i)=(Rpref-Rortho)/(Rpref+Rortho);
    tunewidth(i)=abs(sigma*sqrt(2*log(2))); %calculate tuning width as Ackerboom 2012
        
%     if OSI(i)<0.5 %only tuned cells have tune widths (Niell 2008)
%         tunewidth(i)=NaN;
%     end
    
    %------Calculate Tuning Curve Peak------
    if OSI(i)>=0.5    
%         orientation_adjust=45*(calc_pref_or-1); %adjusts relative tuning curve to be in terms of original orientation
%         tunepeak(i)=max(sigma)+orientation_adjust;
          tunepref(i)=45*(calc_pref_or-1); %inexact version of the above
    end
    
    
end
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


%% Calculate modified Z-scores from Suite2P selected ROIs
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


