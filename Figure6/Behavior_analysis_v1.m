%https://sanworks.github.io/Bpod_Wiki/function-reference/running-statemachine/
% page to understand sessiondata.mat


%% save all SessionData files
clearvars -except behavior_data
for ii = 1: length(behavior_data)
       if isempty (behavior_data(ii).Sessionname)
 
            behavior_data (ii).directory = strcat (behavior_data (ii).folder, '\',num2str(behavior_data (ii).mpi),'mpi');
            fid = fopen( strcat(behavior_data(ii).directory,'\', 'path.txt'),'r');
          
            
            i = 1;
            while ~feof(fid)
                file_data_all{i,1} = fgetl(fid);    
                i = i+1;
            end
            fclose(fid);
        
            if ~contains(file_data_all, getenv('USERPROFILE'))
                file_data_all  = strrep (file_data_all,extractBefore(file_data_all,'\Box'),getenv('USERPROFILE'));
            end
        
            behavior_data (ii). Sessionname = file_data_all;
            
              for jj = 1: length(behavior_data (ii). Sessionname)
               load (behavior_data (ii). Sessionname{jj})
               behavior_data (ii).datafile {jj} = SessionData;
            
              end
            
clearvars file_data_all 
fprintf('The iteration is %d\n', ii)
      end
end 
 %% add trials

clearvars -except behavior_data
for ii = 1: length(behavior_data)
    
    behavior_data (ii).directory = strcat (behavior_data (ii).folder, '\',num2str(behavior_data (ii).mpi),'mpi');
    fid2 = fopen( strcat(behavior_data(ii).directory,'\', 'trial.txt'),'r');
    
    i = 1;
    while ~feof(fid2)
        readtrial{1,i} = fgetl(fid2);    
        i = i+1;
    end
    fclose(fid2);
    
    for jj = 1: length(readtrial)
    a =  str2double(split(readtrial{jj},','));
    starttrial(jj) = a(1);
    endtrial(jj) = a (2);
    end
    trial = [starttrial' endtrial'];
    behavior_data (ii). trial = trial;

    clearvars trial  starttrial endtrial readtrial

   fprintf('The iteration is %d\n', ii)
end
%%  calculate threshold coherence without 90
clearvars -except behavior_data  


for ii = 1:size(behavior_data,2)
    
    correctall_comb = []; coherenceall_comb = [];
    
    for itr = 1: size(behavior_data(ii).datafile,2)
    SessionData = behavior_data(ii).datafile{1,itr};
  
    try
     NumInternalCtrl = SessionData.NumInternalCtrl;
    catch
     NumInternalCtrl = 3;
    end
    
    % get the trial starts and ends of training and testing
    starttrial = behavior_data(ii).trial (itr,1);  endtrial = behavior_data(ii).trial (itr,2);
    nTrials = (endtrial - starttrial) + 1 ;
    Trial_testing = (starttrial+NumInternalCtrl): (NumInternalCtrl+1): endtrial;
    alltrial =  starttrial:endtrial;
    Trial_training = setdiff(alltrial, Trial_testing);
        
    
    % D' in training blocks 
    
    hits_training = 0;
    for k = 1:numel(Trial_training)
        if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.Hit(1))
           hits_training = hits_training + 1;
        end
    end
    
    miss_training = 0;
    for k = 1:numel(Trial_training)
        if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.Miss(1))
           miss_training = miss_training + 1;
        end
    end
    
    
    FA_training = 0;
    for k = 1:numel(Trial_training)
        if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.FalseAlarm(1))
           FA_training = FA_training + 1;
        end
    end
    
    CR_training = 0;
    for k = 1:numel(Trial_training)
        if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.CorrectRejection(1))
           CR_training = CR_training + 1;
        end
    end
    
    if hits_training == 0
        % hits_training = 0.000001;
       hits_training = 1;
    end
    
    if miss_training == 0
        % miss_training = 0.000001;
        miss_training = 1;
    end
    
    if FA_training == 0
        % FA_training = 0.000001;
        FA_training = 1;
    end
    
    if CR_training == 0
        % CR_training = 0.000001;
        CR_training = 1;
    end
    
    D_prime = norminv(hits_training/(hits_training+miss_training))-norminv(FA_training/(FA_training+CR_training));
    if D_prime >= 1.75 && D_prime < 1.8
        D_prime = round(D_prime,1);
    end
    
    behavior_data(ii).dprime_train(itr,1) = D_prime; 
    behavior_data(ii).correct_session (itr,11) = hits_training + CR_training;

    
%  percentage of correct at each coherence in testing blocks
     
    coherence = SessionData.CoherenceTypes(Trial_testing);
     
    correct = zeros(1,length(coherence));
        for i = 1: length(coherence)
            if ~isnan(SessionData.RawEvents.Trial{Trial_testing(i)}.States.Hit(1)) || ~isnan(SessionData.RawEvents.Trial{Trial_testing(i)}.States.CorrectRejection(1))
             correct(i) = 1;
            end
        end
     
     nblock = floor (nTrials/((NumInternalCtrl+1)*10));
     [coherence_sorted,idx] = sort (coherence);
     correct_sorted = correct(idx);
     correct_sorted = correct_sorted (1: (nblock * 10));
     correct_coh = [];
     for jj = 1:nblock:length(correct_sorted)
         correct_coh_temp = sum(correct_sorted(jj:(jj+ nblock-1)));    
         correct_coh  = [correct_coh correct_coh_temp];
     end
  
     behavior_data(ii).correct_session (itr,1:10) = correct_coh;
     behavior_data(ii).ntrial_session (itr,1) = nblock;  
     behavior_data(ii).ntrial_session (itr,2) = length(Trial_training);  
     behavior_data(ii).correct  = sum(behavior_data(ii).correct_session(:,1:10))/sum(behavior_data(ii).ntrial_session(:,1))*100;
     behavior_data(ii).correct (1,11) = sum(behavior_data(ii).correct_session (:,11))/sum(behavior_data(ii).ntrial_session(:,2))*100;
    

   % predict the threshold and slope

   coherenceall = SessionData.CoherenceTypes (starttrial:endtrial);
   correctall = zeros(1,length(alltrial)); 
   jj = 1;
   for zz = starttrial: endtrial
        if ~isnan(SessionData.RawEvents.Trial{1,zz}.States.Hit(1)) || ~isnan(SessionData.RawEvents.Trial{1,zz}.States.CorrectRejection(1))
         correctall(jj) = 1;
         jj = jj + 1;
        end
   end
    
   % exclude 90%
     correctall_comb = [correctall_comb correct]; coherenceall_comb = [coherenceall_comb coherence];
    % include 90%
%     correctall_comb = [correctall_comb correctall]; coherenceall_comb = [coherenceall_comb coherenceall];
     
    end
     results.intensity = coherenceall_comb;
     results.response =  correctall_comb;      
    
     % to find the best threshold and slope
     pInit.t = 0.50;
     pInit.b = 1.00;
      
     [pBest,logLikelihoodBest] = fit('fitPsychometricFunction',pInit,{'b','t'},results,'Weibull');  
     behavior_data(ii).threshold (1,1) = pBest.t;
     behavior_data(ii).threshold (1,2) = pBest.b;
     if pBest.t > 0.9
         pBest.t = 0.9;
     end
     behavior_data(ii).threshold_adjust (1,1) = pBest.t;

     clearvars correctall_comb coherenceall_comb


end
%%  calculate threshold coherence WITH 90
% clearvars -except behavior_data  


 for ii = 1:size(behavior_data,2)

    correctall_comb = []; coherenceall_comb = [];
    
    for itr = 1: size(behavior_data(ii).datafile,2)
    SessionData = behavior_data(ii).datafile{1,itr};
  
    try
     NumInternalCtrl = SessionData.NumInternalCtrl;
    catch
     NumInternalCtrl = 3;
    end
    
    % get the trial starts and ends of training and testing
    starttrial = behavior_data(ii).trial (itr,1);  endtrial = behavior_data(ii).trial (itr,2);
    nTrials = (endtrial - starttrial) + 1 ;
    Trial_testing = (starttrial+NumInternalCtrl): (NumInternalCtrl+1): endtrial;
    alltrial =  starttrial:endtrial;
    Trial_training = setdiff(alltrial, Trial_testing);
        
    
    % D' in training blocks 
    
    hits_training = 0;
    for k = 1:numel(Trial_training)
        if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.Hit(1))
           hits_training = hits_training + 1;
        end
    end
    
    miss_training = 0;
    for k = 1:numel(Trial_training)
        if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.Miss(1))
           miss_training = miss_training + 1;
        end
    end
    
    
    FA_training = 0;
    for k = 1:numel(Trial_training)
        if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.FalseAlarm(1))
           FA_training = FA_training + 1;
        end
    end
    
    CR_training = 0;
    for k = 1:numel(Trial_training)
        if ~isnan(SessionData.RawEvents.Trial{Trial_training(k)}.States.CorrectRejection(1))
           CR_training = CR_training + 1;
        end
    end
    
    if hits_training == 0
       hits_training = 0.000001;
%        hits_training = 1;
    end
    
    if miss_training == 0
        miss_training = 0.000001;
%         miss_training = 1;
    end
    
    if FA_training == 0
        FA_training = 0.000001;
%         FA_training = 1;
    end
    
    if CR_training == 0
        CR_training = 0.000001;
%         CR_training = 1;
    end
    
    D_prime = norminv(hits_training/(hits_training+miss_training))-norminv(FA_training/(FA_training+CR_training));
    if D_prime >= 1.75 && D_prime < 1.8
        D_prime = round(D_prime,1);
    end
    
    behavior_data(ii).dprime_train(itr,1) = D_prime; 
    behavior_data(ii).correct_session (itr,11) = hits_training + CR_training;

    
%  percentage of correct at each coherence in testing blocks
     
    coherence = SessionData.CoherenceTypes(Trial_testing);     
    correct = zeros(1,length(coherence));
        for i = 1: length(coherence)
            if ~isnan(SessionData.RawEvents.Trial{Trial_testing(i)}.States.Hit(1)) || ~isnan(SessionData.RawEvents.Trial{Trial_testing(i)}.States.CorrectRejection(1))
             correct(i) = 1;
            end
        end
   % find correct trial at 90 coherence 
     
    correct90 = zeros(1,length(Trial_training));
        for i = 1: length(Trial_training)
            if ~isnan(SessionData.RawEvents.Trial{Trial_training(i)}.States.Hit(1)) || ~isnan(SessionData.RawEvents.Trial{Trial_training(i)}.States.CorrectRejection(1))
             correct90(i) = 1;
            end
        end
    
        
     nblock = floor (nTrials/((NumInternalCtrl+1)*10));
     correct90 = correct90 (1: NumInternalCtrl* nblock*10);
     correct90 = reshape (correct90, (NumInternalCtrl*10),nblock); 
     correct90 = mean(correct90,1);

     coherence90 = [coherence ones(1,nblock)*90];
     correct90 = [correct correct90];

     
     [coherence_sorted,idx] = sort (coherence);
     correct_sorted = correct(idx);
     correct_sorted = correct_sorted (1: (nblock * 10));
     correct_coh = [];
     for jj = 1:nblock:length(correct_sorted)
         correct_coh_temp = sum(correct_sorted(jj:(jj+ nblock-1)));    
         correct_coh  = [correct_coh correct_coh_temp];
     end
  
     behavior_data(ii).correct_session (itr,1:10) = correct_coh;
     behavior_data(ii).ntrial_session (itr,1) = nblock;  
     behavior_data(ii).ntrial_session (itr,2) = length(Trial_training);  
     behavior_data(ii).correct  = sum(behavior_data(ii).correct_session(:,1:10))/sum(behavior_data(ii).ntrial_session(:,1))*100;
     behavior_data(ii).correct (1,11) = sum(behavior_data(ii).correct_session (:,11))/sum(behavior_data(ii).ntrial_session(:,2))*100;
    

   % predict the threshold and slope

   coherenceall = SessionData.CoherenceTypes (starttrial:endtrial);
   correctall = zeros(1,length(alltrial)); 
   jj = 1;
   for zz = starttrial: endtrial
        if ~isnan(SessionData.RawEvents.Trial{1,zz}.States.Hit(1)) || ~isnan(SessionData.RawEvents.Trial{1,zz}.States.CorrectRejection(1))
         correctall(jj) = 1;
         jj = jj + 1;
        end
   end
    
   % exclude 90%
%      correctall_comb = [correctall_comb correct]; coherenceall_comb = [coherenceall_comb coherence];
    % include 90%
    correctall_comb = [correctall_comb correct90]; coherenceall_comb = [coherenceall_comb coherence90];
     
    end
     results.intensity = coherenceall_comb;
     results.response =  correctall_comb;      
    
     % to find the best threshold and slope
     pInit.t = 0.50;
     pInit.b = 1.00;
      
     [pBest,logLikelihoodBest] = fit('fitPsychometricFunction',pInit,{'b','t'},results,'Weibull');  
     behavior_data(ii).threshold (1,1) = pBest.t;
     behavior_data(ii).threshold (1,2) = pBest.b;
     if pBest.t > 0.9
         pBest.t = 0.9;
     end
     behavior_data(ii).threshold_adjust90 (1,1) = pBest.t;

     clearvars correctall_comb coherenceall_comb


 end


% find #trial per test session
% aa = arrayfun(@(s) s.ntrial_session(:,2), behavior_datamini, 'UniformOutput', false);
% mean(cellfun(@mean, aa))

%find #trials per test coherence
%cc= arrayfun(@(s) s.ntrial_session(:,1), behavior_datamini, 'UniformOutput', false);
%mean(cellfun(@sum, cc))
%mean(cellfun(@length, cc))
%%
clearvars -except behavior_data 
for zz = 1: size(behavior_data,2)
 
    for itr = 1: size(behavior_data(zz).datafile,2)

        
            SessionData = behavior_data(zz).datafile{1,itr};
            try
             NumInternalCtrl = SessionData.NumInternalCtrl;
            catch
             NumInternalCtrl = 3;
            end          
            
            starttrial = behavior_data(zz).trial (itr,1);  endtrial = behavior_data(zz).trial (itr,2);
            nTrials = (endtrial - starttrial) + 1 ;
            nblock = floor (nTrials/((NumInternalCtrl+1)*10));
            nTrials = nblock*10* (NumInternalCtrl+1) ; endtrial = round(starttrial+ nTrials-1);

%             responsetime = SessionData.RawEvents.Trial{1,2}.States.WaitForResponse;

           
            Trial_testing = (starttrial+NumInternalCtrl): (NumInternalCtrl+1): endtrial;
            alltrial =  starttrial:endtrial;
            Trial_training = setdiff(alltrial, Trial_testing);
        
            coherenceall = SessionData.CoherenceTypes (1:behavior_data(zz).datafile{1,itr}.nTrials);
            % 1st row = coh; 2nd = hit (1), Miss = 2, CR = 3; FA = 4; 
            % 3rd =  response time; 4th = trialtype; 5 = hit_resptime; 
            % 6 = FA_resptime
   
         
            for ii = 1 : behavior_data(zz).datafile{1,itr}.nTrials
        
                if ~isnan(SessionData.RawEvents.Trial{ii}.States.Hit(1))
                    coherenceall (2,ii) = 1;
                    %coherenceall (6,ii) = length(SessionData.RawEvents.Trial{1,ii}.States.Drinking)+length(SessionData.RawEvents.Trial{1,ii}.States.DrinkingGrace);  % # lickfreq
                    %coherenceall (7,ii) = SessionData.RawEvents.Trial{1,ii}.States.Drinking (end,2) -  SessionData.RawEvents.Trial{1,ii}.States.Drinking (1,1); % licking duration
                    [lick,~] = min(find(SessionData.RawEvents.Trial{1,ii}.Events.DIO1_2_Hi>=1.5));
                    if lick == 1
                        prelick = NaN;
                        coherenceall (8,ii) = 0;  % prelick frequency
                        postlick = SessionData.RawEvents.Trial{1,ii}.Events.DIO1_2_Hi(lick:end);
                    else
                        prelick = SessionData.RawEvents.Trial{1,ii}.Events.DIO1_2_Hi(1:lick-1);
                        postlick = SessionData.RawEvents.Trial{1,ii}.Events.DIO1_2_Hi(lick:end);
                    end
                    
                    coherenceall (6,ii) = length(postlick);              % # lickfreq
                    coherenceall (7,ii) = postlick(end)-prelick(1);  % licking duration for whole trial                 
                    coherenceall (11,ii) = min(SessionData.RawEvents.Trial{1,ii}.Events.DIO1_2_Hi); 
                elseif ~isnan(SessionData.RawEvents.Trial{ii}.States.Miss(1))
                    coherenceall (2,ii) = 2;
                    coherenceall (6,ii) = NaN;
                    coherenceall (7,ii) = NaN;
                    
                elseif ~isnan(SessionData.RawEvents.Trial{ii}.States.CorrectRejection(1))
                    coherenceall (2,ii) = 3;
                    coherenceall (6,ii) = NaN;
                    coherenceall (7,ii) = NaN;
                    
                elseif ~isnan(SessionData.RawEvents.Trial{ii}.States.FalseAlarm(1))
                     coherenceall (2,ii) = 4;
                     [lick,~] = min(find(SessionData.RawEvents.Trial{1,ii}.Events.DIO1_2_Hi>=1.5));
                    if lick == 1
                        prelick = NaN;
                        coherenceall (8,ii) = 0;   % prelick frequency
                        postlick = SessionData.RawEvents.Trial{1,ii}.Events.DIO1_2_Hi(lick:end);
                    else
                        prelick = SessionData.RawEvents.Trial{1,ii}.Events.DIO1_2_Hi(1:lick-1);
                        postlick = SessionData.RawEvents.Trial{1,ii}.Events.DIO1_2_Hi(lick:end);
                    end
                    
                    coherenceall (6,ii) = length(postlick);              % # lickfreq
                    coherenceall (7,ii) = postlick(end)-prelick(1);  % licking duration                    
                    coherenceall (11,ii) = min(SessionData.RawEvents.Trial{1,ii}.Events.DIO1_2_Hi); 
                     
                end      
                
                coherenceall (3,ii) = SessionData.RawEvents.Trial{ii}.States.WaitForResponse(2) - SessionData.RawEvents.Trial{ii}.States.WaitForResponse(1); 
                coherenceall (4,ii) = SessionData.TrialTypes(ii);
                coherenceall (5,ii) = SessionData.RawEvents.Trial{ii}.States.StopGlobalTimer(1,2); % Trial duration
                coherenceall (8,ii) =  coherenceall (6,ii)/(coherenceall (5,ii)-1.5); % #lick normalized to trial duration (post)
                coherenceall (9,ii) =  coherenceall (7,ii); % licking duration normalized to trial duration (post)
                coherenceall (10,ii) =  coherenceall (8,ii)/1.5; % #lick normalized to trial duration (pre)

                clearvars lick prelick postlick
                
            end
        
             coherencetest = coherenceall(:,Trial_testing);
             coherencetrain = coherenceall(:,Trial_training);
             [coherence_sorted,idx] = sort (coherencetest(1,:));
             coherencetest_sort = coherencetest(:,idx);

             
             clearvars ii 
             hit_resptime = nan (1,10); FA_resptime = nan (1,10);
             jj = 1; 
             for ii = 1:nblock:size(coherencetest_sort,2)
                 hit_idx = find(coherencetest_sort(2,ii:(nblock+ii-1)) == 1);
                 hit_resptime (jj) = mean(coherencetest_sort(3,hit_idx));
                 hit_postlickfreq (jj) = mean(coherencetest_sort(8,hit_idx)); 
                 hit_postlicktime (jj) = mean(coherencetest_sort(9,hit_idx)); 
                 hit_prelickfreq (jj) = mean(coherencetest_sort(10,hit_idx)); 
                 hit_firstlick (jj) = mean(coherencetest_sort(11,hit_idx)); 
                 FA_idx = find(coherencetest_sort(2,ii:(nblock+ii-1)) == 4);
                 FA_resptime (jj) = mean(coherencetest_sort(3,FA_idx));
                 FA_postlickfreq (jj) = mean(coherencetest_sort(8,FA_idx)); 
                 FA_postlicktime (jj) = mean(coherencetest_sort(9,FA_idx)); 
                 FA_prelickfreq (jj) = mean(coherencetest_sort(10,FA_idx)); 
                 FA_firstlick (jj) = mean(coherencetest_sort(11,FA_idx)); 
                 nGo (jj) = length(find (coherencetest_sort(4,ii:(nblock+ii-1)) == 1));
                 nNoGo (jj) = length(find (coherencetest_sort(4,ii:(nblock+ii-1)) == 2));
                 correctGo (jj) = 0; correctNoGo (jj) = 0;
                 for kk = ii: nblock+ii-1
                     if coherencetest_sort(2,kk) == 1 && coherencetest_sort(4,kk) == 1 % hit for Go
                         correctGo (jj)  = correctGo (jj) + 1;
                     elseif coherencetest_sort(2,kk) == 3 && coherencetest_sort(4,kk) == 2 % CR for NoGo
                         correctNoGo (jj) = correctNoGo (jj) + 1;          
                     end
                 end
                 perc_correctGo (jj) = correctGo(jj)/nGo(jj)*100;
                 perc_correctNoGo (jj) = correctNoGo(jj)/nNoGo(jj)*100;
                 perc_nGo (jj) = nGo(jj)/(nGo(jj)+ nNoGo(jj))*100;
                 perc_nNoGo (jj) = nNoGo(jj)/(nGo(jj)+ nNoGo(jj))*100;
                 jj = jj + 1;
             end
         cohinfo = [hit_resptime;FA_resptime; perc_correctGo; perc_correctNoGo; ...
                   perc_nGo;perc_nNoGo;...
                   hit_postlickfreq; hit_postlicktime; hit_prelickfreq; hit_firstlick;
                   FA_postlickfreq; FA_postlicktime; FA_prelickfreq; FA_firstlick];
         behavior_data(zz).cohinfo{itr} = cohinfo;
         behavior_data(zz).coherenceall{itr} = coherenceall;
         behavior_data(zz).Trial_test{itr} = Trial_testing;
         behavior_data(zz).Trial_train{itr} = Trial_training;

% 1st row = coh; 
% 2nd = hit (1), Miss = 2, CR = 3; FA = 4; 
% 3rd =  response time; 
% 4th = trialtype; 
% 5 = trial duration; 
% 6= # lick (post)
% 7= post licking duration
% 8 = postlick duration normalized
% 9 = postlick frequency normalized
% 10 = prelick frequency normalized
% 11 = licking duration all
   

%         catch ME
%             fprintf('%s Iteration #%d.\n', ME.message,zz) %display error msg & iteration #
%             fprintf('%s Iteration #%d.\n', ME.message,itr) %display error msg & iteration #
%         end

fprintf('The iteration is %d\n', zz)
    end
end

%%  correlation __ response time across session
clearvars -except behavior_data 

gort8_mouse = []; gocorrect8_mouse = [];  gort8_idx_mouse =[]; gort8_ori_mouse = [];
nogort8_mouse = []; nogocorrect8_mouse = []; nogort8_idx_mouse =[]; nogort8_ori_mouse = [];
gort80_mouse = []; gocorrect80_mouse = []; gort80_idx_mouse =[]; gort80_ori_mouse = [];
nogort80_mouse = []; nogocorrect80_mouse = []; nogort80_idx_mouse =[]; nogort80_ori_mouse = []; 

for zz = 1: size(behavior_data,2) 
    for itr = 1: size(behavior_data(zz).datafile,2)    
        SessionData = behavior_data(zz).datafile{1,itr};
        try
         NumInternalCtrl = SessionData.NumInternalCtrl;
        catch
         NumInternalCtrl = 3;
        end    
starttrial = behavior_data(zz).trial (itr,1);  endtrial = behavior_data(zz).trial (itr,2);
nTrials = (endtrial - starttrial) + 1 ;
nblock = floor (nTrials/((NumInternalCtrl+1)*10));
nTrials = nblock*10* (NumInternalCtrl+1) ; endtrial = round(starttrial+ nTrials-1);

Trial_testing = (starttrial+NumInternalCtrl): (NumInternalCtrl+1): endtrial;
alltrial =  starttrial:endtrial;
Trial_training = setdiff(alltrial, Trial_testing);
coherenceall = SessionData.CoherenceTypes (starttrial:endtrial);
[coherence_sorted,idx] = sort (coherenceall(1,:));


correctall = zeros(1,length(alltrial)); 
  for ii = starttrial : endtrial       
        resptime (1,ii) = SessionData.RawEvents.Trial{ii}.States.WaitForResponse(2) - SessionData.RawEvents.Trial{ii}.States.WaitForResponse(1); 
        SessionData.TrialTypes(ii);
        if ~isnan(SessionData.RawEvents.Trial{1,ii}.States.Hit(1)) || ~isnan(SessionData.RawEvents.Trial{1,ii}.States.CorrectRejection(1))
         correctall(ii) = 1;
        
        end
  end

coherenceall_sort = coherenceall(:,idx);
resptime_sort = resptime(:,idx);
TrialTypes = SessionData.TrialTypes(starttrial:endtrial);
TrialTypes_sort = TrialTypes(:,idx);
correctall_sort = correctall (:,idx);


% 8%
rt8 = resptime_sort (1:nblock);  correct8 = correctall_sort (1:nblock);
[~, go8_idx] = find (TrialTypes_sort(1:nblock) == 1); 
[~, nogo8_idx] = find (TrialTypes_sort(1:nblock) == 2); 
gort8 = rt8(go8_idx);
nogort8 = rt8(nogo8_idx);
gocorrect8 = correct8 (go8_idx);
nogocorrect8 = correct8 (nogo8_idx);
gort8_ori = gort8; nogort8_ori = nogort8; 
gort8 (gocorrect8 == 0) = NaN;
nogort8 (nogocorrect8 == 1) = NaN;

 gort8_mouse  = [gort8_mouse gort8];
 gort8_ori_mouse  = [gort8_ori_mouse gort8_ori];
 gocorrect8_mouse = [gocorrect8_mouse gocorrect8];
 gort8_idx_mouse = [gort8_idx_mouse 1:length(gort8)];
 nogort8_mouse  = [nogort8_mouse nogort8];
 nogort8_ori_mouse  = [nogort8_ori_mouse nogort8_ori];
 nogocorrect8_mouse  = [nogocorrect8_mouse nogocorrect8];
 nogort8_idx_mouse = [nogort8_idx_mouse 1:length(nogort8)];

% 80%
rt80 = resptime_sort ((nblock*9)+1:(nblock*9)+nblock);  correct80 = correctall_sort ((nblock*9)+1:(nblock*9)+nblock);
[~, go80_idx] = find (TrialTypes_sort((nblock*9)+1:(nblock*9)+nblock) == 1); 
[~, nogo80_idx] = find (TrialTypes_sort((nblock*9)+1:(nblock*9)+nblock) == 2); 
gort80 = rt80(go80_idx);
nogort80 = rt80(nogo80_idx);
gocorrect80 = correct80 (go80_idx);
nogocorrect80 = correct80 (nogo80_idx);
gort80_ori = gort80; nogort80_ori = nogort80; 
gort80 (gocorrect80 == 0) = NaN;
nogort80 (nogocorrect80 == 1) = NaN;

 gort80_mouse  = [gort80_mouse gort80];
 gort80_ori_mouse  = [gort80_ori_mouse gort80_ori];
 gocorrect80_mouse  = [gocorrect80_mouse gocorrect80];
 gort80_idx_mouse = [gort80_idx_mouse 1:length(gort80)];
 nogort80_mouse  = [nogort80_mouse nogort80];
 nogort80_ori_mouse  = [nogort80_ori_mouse nogort80_ori];
 nogocorrect80_mouse  = [nogocorrect80_mouse nogocorrect80];
 nogort80_idx_mouse = [nogort80_idx_mouse 1:length(nogort80)];
 end


% response time vs session stage  

 [a,b] = corrcoef(gort8_idx_mouse, gort8_mouse,'row','complete');
 [c,d] = corrcoef(nogort8_idx_mouse, nogort8_mouse,'row','complete');

 [e,f] = corrcoef(gort80_idx_mouse, gort80_mouse,'row','complete');
 [g,h] = corrcoef(nogort80_idx_mouse, nogort80_mouse,'row','complete');

 % response time hit vs correct or response time FA vs correct separately
 [iiii,j] = corrcoef(gocorrect8_mouse, gort8_ori_mouse,'row','complete');
 [k,l] = corrcoef(nogocorrect8_mouse, nogort8_ori_mouse,'row','complete');

 [m,n] = corrcoef(gocorrect80_mouse, gort80_ori_mouse,'row','complete');
 [o,p] = corrcoef(nogocorrect80_mouse, nogort80_ori_mouse,'row','complete');

% hit or FA response time vs correct (hit == 1 and FA == 0)
 [q,r] = corrcoef([gocorrect8_mouse nogocorrect8_mouse], [gort8_mouse nogort8_mouse],'row','complete');
 [s,t] = corrcoef([gocorrect80_mouse nogocorrect80_mouse], [gort80_mouse nogort80_mouse],'row','complete');

 behavior_data(zz).go8 = [gort8_mouse q(1,2) iiii(1,2) a(1,2);gort8_idx_mouse r(1,2) j(1,2) b(1,2)];
 behavior_data(zz).nogo8 = [nogort8_mouse k(1,2) c(1,2);  nogort8_idx_mouse l(1,2) d(1,2)];
 behavior_data(zz).go80 = [gort80_mouse s(1,2) m(1,2) e(1,2);gort80_idx_mouse t(1,2) n(1,2) f(1,2)];
 behavior_data(zz).nogo80 = [nogort80_mouse o(1,2) g(1,2);  nogort80_idx_mouse p(1,2) h(1,2)];
end
%% segmenting the session --- 50 trials each for initial, middle and final

clearvars -except behavior_data

 for jj = 1: length(behavior_data)

if ~isempty (behavior_data(jj).Sessionname)
ID = unique (behavior_data(jj).Sessionname);
[C,ia,ib] = intersect(behavior_data(jj).Sessionname,ID, 'stable');
ntrialeach = behavior_data(jj).trial(:,2)-behavior_data(jj).trial(:,1)+1;
for ii = 1 : length(ID)
     kk = ii + 1;
     if ii ~= length(ID)
     ntrialuniq (ii) = sum(ntrialeach(ia(ii): (ia(kk)-1)));
     else 
     ntrialuniq (ii) = sum(ntrialeach(ia(ii): end));
     end
end

col = [];
for ii = 1:length(behavior_data(jj).trial)
col = [col behavior_data(jj).trial(ii,1):behavior_data(jj).trial(ii,2)];
end

trial_cell = mat2cell(col,1,ntrialuniq);


% create initial, middle and final segments
for zz = 1:length(ID)
    if ntrialuniq (zz) >= 150
    % trial_indices (row 1)
    initial{1,zz} = trial_cell{1,zz}(1,1:50);
    final{1,zz} = trial_cell{1,zz}(1,ntrialuniq (zz)-49:ntrialuniq (zz));
    middle{1,zz} = trial_cell{1,zz}(1,ntrialuniq (zz)/2:(49+ntrialuniq (zz)/2));    

    % Go = 1; Nogo = 0; (row 2)
    initial{2,zz} = behavior_data(jj).datafile{1,ia(zz)}.TrialTypes(initial{1,zz});
    middle{2,zz} = behavior_data(jj).datafile{1,ia(zz)}.TrialTypes(middle{1,zz});
    final{2,zz} = behavior_data(jj).datafile{1,ia(zz)}.TrialTypes(final{1,zz});
    initial{2,zz}(initial{2,zz}==2)=0; middle{2,zz}(middle{2,zz}==2)=0; final{2,zz}(final{2,zz}==2)=0;

    %  hit = 1, Miss = 2, CR = 3; FA = 4; (row 3)
    initial{3,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(2,initial{1,zz});
    middle{3,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(2,middle{1,zz});
    final{3,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(2,final{1,zz});

    %  Response time (row 4)
    initial{4,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(3,initial{1,zz});
    middle{4,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(3,middle{1,zz});
    final{4,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(3,final{1,zz});
    initial{4,zz}(initial{4,zz}>=2.5)=NaN; middle{4,zz}(middle{4,zz}>=2.5)=NaN; final{4,zz}(final{4,zz}>=2.5)=NaN;

    %  hit Response time (row 5)
%     initial{5,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(5,initial{1,zz});
%     middle{5,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(5,middle{1,zz});
%     final{5,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(5,final{1,zz});
% 
%     %  FA Response time (row 6)
%     initial{6,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(6,initial{1,zz});
%     middle{6,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(6,middle{1,zz});
%     final{6,zz} = behavior_data(jj).coherenceall{1,ia(zz)}(6,final{1,zz});
%     

    else
    initial{1,zz} = NaN;   middle{1,zz} = NaN; final{1,zz} = NaN;  
    initial{2,zz} = NaN;   middle{2,zz} = NaN; final{2,zz} = NaN; 
    initial{3,zz} = NaN;   middle{3,zz} = NaN; final{3,zz} = NaN; 
    initial{4,zz} = NaN;   middle{4,zz} = NaN; final{4,zz} = NaN; 
%     initial{5,zz} = NaN;   middle{5,zz} = NaN; final{5,zz} = NaN; 
%     initial{6,zz} = NaN;   middle{6,zz} = NaN; final{6,zz} = NaN; 
   
       
   
    end
    
end

% add info in initial, middle and final segments




behavior_data (jj).Session_unique = C;
behavior_data (jj).Sessionidx_unique = ia;
behavior_data (jj).ntrial_unique = ntrialuniq;
behavior_data (jj).trial_seq = trial_cell;
behavior_data (jj).initial = initial;
behavior_data (jj).middle = middle;
behavior_data (jj).final = final;

clearvars C ia ID ntrialuniq ntrialeach initial middle final
end
end

%%
colorstring = 'grb';
fillcolor = 'grw';
x = 1:length(gocorrect8);
figure(1)
for ii = 1:length(gocorrect8)
    if gocorrect8(ii) == 1
       plot(x(1,ii),gort80(ii), 'o','Color', colorstring(1),'MarkerFaceColor', fillcolor(1))
    else
%        plot(x(1,ii),gort8(ii), 'o','Color', colorstring(2),'MarkerFaceColor', fillcolor(2))
       continue;
    end
    hold on
end

clearvars x 
figure(2)
x = 1:length(nogocorrect8);
for ii = 1:length(nogocorrect8)
    if nogocorrect8(ii) == 1
       plot(x(1,ii),nogort80(ii), 'o','Color', colorstring(1),'MarkerFaceColor', fillcolor(1))
    else
%         plot(x(1,ii),nogort8(ii), 'o','Color', colorstring(2),'MarkerFaceColor', fillcolor(2))
        continue;
    end
    hold on
end



%% making mini
behavior_datamini = behavior_data;
behavior_datamini = rmfield(behavior_datamini, 'datafile');
% save ('behavior_datamini.mat', 'behavior_datamini')

%% using mini
clearvars -except behavior_data behavior_datamini

for ii = 1: length (behavior_datamini) 
    kk = 1;
    for jj = 1:length(behavior_datamini(ii).cohinfo)
       behavior_datamini(ii).hit_resptime (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(1,:);
       behavior_datamini(ii).FA_resptime (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(2,:);
       behavior_datamini(ii).perc_correctGo (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(3,:);
       behavior_datamini(ii).perc_correctNoGo (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(4,:);
       behavior_datamini(ii).perc_nGo (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(5,:);
       behavior_datamini(ii).perc_nNoGo (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(6,:);  
       behavior_datamini(ii).hit_postlickfreq (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(7,:);
       behavior_datamini(ii).hit_postlicktime (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(8,:);
       behavior_datamini(ii).hit_prelickfreq (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(9,:);
       behavior_datamini(ii).hit_firstlick (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(10,:);
       behavior_datamini(ii).FA_postlickfreq (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(11,:);
       behavior_datamini(ii).FA_postlicktime (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(12,:);
       behavior_datamini(ii).FA_prelickfreq (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(13,:);
       behavior_datamini(ii).FA_firstlick (kk,:) = behavior_datamini(ii).cohinfo{1,jj}(14,:);      
       kk = kk + 1;
    end
    

    for zz = 1 : size (behavior_datamini(ii).initial,2)
       behavior_datamini(ii).initial_hitrate (zz,:) = sum(behavior_datamini(ii).initial{3,zz}==1)/sum(behavior_datamini(ii).initial{2,zz}==1);
       behavior_datamini(ii).initial_FArate (zz,:) = sum(behavior_datamini(ii).initial{3,zz}==4)/sum(behavior_datamini(ii).initial{2,zz}==0);
       behavior_datamini(ii).middle_hitrate (zz,:) = sum(behavior_datamini(ii).middle{3,zz}==1)/sum(behavior_datamini(ii).middle{2,zz}==1);
       behavior_datamini(ii).middle_FArate (zz,:) = sum(behavior_datamini(ii).middle{3,zz}==4)/sum(behavior_datamini(ii).middle{2,zz}==0);
       behavior_datamini(ii).final_hitrate (zz,:) = sum(behavior_datamini(ii).final{3,zz}==1)/sum(behavior_datamini(ii).final{2,zz}==1);
       behavior_datamini(ii).final_FArate (zz,:) = sum(behavior_datamini(ii).final{3,zz}==4)/sum(behavior_datamini(ii).final{2,zz}==0);
       behavior_datamini(ii).initial_resptime (zz,:) = mean(behavior_datamini(ii).initial{4,zz},'omitnan');
       behavior_datamini(ii).middle_resptime (zz,:) = mean(behavior_datamini(ii).middle{4,zz},'omitnan');
       behavior_datamini(ii).final_resptime (zz,:) = mean(behavior_datamini(ii).final{4,zz},'omitnan');
%        behavior_datamini(ii).initial_hitresptime (zz,:) = mean(behavior_datamini(ii).initial{5,zz},'omitnan');
%        behavior_datamini(ii).initial_FAresptime (zz,:) = mean(behavior_datamini(ii).initial{6,zz},'omitnan');
%        behavior_datamini(ii).middle_hitresptime (zz,:) = mean(behavior_datamini(ii).middle{5,zz},'omitnan');
%        behavior_datamini(ii).middle_FAresptime (zz,:) = mean(behavior_datamini(ii).middle{6,zz},'omitnan');
%        behavior_datamini(ii).final_hitresptime (zz,:) = mean(behavior_datamini(ii).final{5,zz},'omitnan');
%        behavior_datamini(ii).final_FAresptime (zz,:) = mean(behavior_datamini(ii).final{6,zz},'omitnan');
       

    end



    behavior_datamini(ii). hit_resptime_avg = mean (behavior_datamini(ii). hit_resptime,"omitnan");
    behavior_datamini(ii). FA_resptime_avg = mean (behavior_datamini(ii). FA_resptime,"omitnan");
    behavior_datamini(ii). perc_correctGo_avg = mean (behavior_datamini(ii). perc_correctGo,"omitnan");
    behavior_datamini(ii). perc_correctNoGo_avg = mean (behavior_datamini(ii). perc_correctNoGo,"omitnan");
    behavior_datamini(ii). perc_nGo_avg = mean (behavior_datamini(ii). perc_nGo);
    behavior_datamini(ii). perc_nNoGo_avg = mean (behavior_datamini(ii).perc_nNoGo);
    behavior_datamini(ii). hit_postlickfreq_avg = mean (behavior_datamini(ii). hit_postlickfreq,"omitnan");
    behavior_datamini(ii). hit_postlicktime_avg = mean (behavior_datamini(ii). hit_postlicktime,"omitnan");
    behavior_datamini(ii). hit_prelickfreq_avg = mean (behavior_datamini(ii). hit_prelickfreq,"omitnan");
    behavior_datamini(ii). hit_firstlick_avg = mean (behavior_datamini(ii). hit_firstlick,"omitnan");
    behavior_datamini(ii). FA_postlickfreq_avg = mean (behavior_datamini(ii). FA_postlickfreq,"omitnan");
    behavior_datamini(ii). FA_postlicktime_avg = mean (behavior_datamini(ii). FA_postlicktime,"omitnan");
    behavior_datamini(ii). FA_prelickfreq_avg = mean (behavior_datamini(ii). FA_prelickfreq,"omitnan");
    behavior_datamini(ii). FA_firstlick_avg = mean (behavior_datamini(ii). FA_firstlick,"omitnan");
    behavior_datamini(ii). initial_hitrate_avg = mean (behavior_datamini(ii). initial_hitrate,"omitnan");
    behavior_datamini(ii). initial_FArate_avg = mean (behavior_datamini(ii). initial_FArate,"omitnan");
    behavior_datamini(ii). middle_hitrate_avg = mean (behavior_datamini(ii). middle_hitrate,"omitnan");
    behavior_datamini(ii). middle_FArate_avg = mean (behavior_datamini(ii). middle_FArate,"omitnan");
    behavior_datamini(ii). final_hitrate_avg = mean (behavior_datamini(ii). final_hitrate,"omitnan");
    behavior_datamini(ii). final_FArate_avg = mean (behavior_datamini(ii). final_FArate,"omitnan");
    behavior_datamini(ii). initial_resptime_avg = mean (behavior_datamini(ii). initial_resptime,"omitnan");
    behavior_datamini(ii). middle_resptime_avg = mean (behavior_datamini(ii). middle_resptime,"omitnan");
    behavior_datamini(ii). final_resptime_avg = mean (behavior_datamini(ii). final_resptime,"omitnan");
%     behavior_datamini(ii). initial_hitresptime_avg = mean (behavior_datamini(ii). initial_hitresptime,"omitnan");
%     behavior_datamini(ii). initial_FAresptime_avg = mean (behavior_datamini(ii). initial_FAresptime,"omitnan");
%     behavior_datamini(ii). middle_hitresptime_avg = mean (behavior_datamini(ii). middle_hitresptime,"omitnan");
%     behavior_datamini(ii). middle_FAresptime_avg = mean (behavior_datamini(ii). middle_FAresptime,"omitnan");
%     behavior_datamini(ii). final_hitresptime_avg = mean (behavior_datamini(ii). final_hitresptime,"omitnan");
%     behavior_datamini(ii). final_FAresptime_avg = mean (behavior_datamini(ii). final_FAresptime,"omitnan");
    behavior_datamini(ii). goR8_avg = behavior_data(ii).go8(1,end);
    behavior_datamini(ii). nogoR8_avg = behavior_data(ii).nogo8(1,end);
    behavior_datamini(ii). goR80_avg = behavior_data(ii).go80(1,end);
    behavior_datamini(ii). nogoR80_avg = behavior_data(ii).nogo80(1,end);
    behavior_datamini(ii). goCR8_avg = behavior_data(ii).go8(1,end-1);
    behavior_datamini(ii). nogoCR8_avg = behavior_data(ii).nogo8(1,end-1);
    behavior_datamini(ii). goCR80_avg = behavior_data(ii).go80(1,end-1);
    behavior_datamini(ii). nogoCR80_avg = behavior_data(ii).nogo80(1,end-1);
    behavior_datamini(ii). hitFACR8_avg = behavior_data(ii).go8(1,end-3);
    behavior_datamini(ii). hitFACR80_avg = behavior_data(ii).nogo8(1,end-3);
    behavior_datamini(ii). hit_resptime8_mpi_avg = mean (behavior_datamini(ii). go8(1,1:end-2),"omitnan");
    behavior_datamini(ii). FA_resptime8_mpi_avg = mean (behavior_datamini(ii). nogo8(1,1:end-2),"omitnan");
    behavior_datamini(ii). hit_resptime80_mpi_avg = mean (behavior_datamini(ii). go80(1,1:end-2),"omitnan");
    behavior_datamini(ii). FA_resptime80_mpi_avg = mean (behavior_datamini(ii). nogo80(1,1:end-2),"omitnan");
    
end


%%

% nogo80_resptime_all = [];
% nogo80_resptime_allS = [];
% nogo80_resptime_allPFF = [];
% 
% for ii = 1: length (behavior_data) 
% 
%     nogo80_resptime_all = [nogo80_resptime_all behavior_data(ii).nogo80(1,1:end-2)];
%     if behavior_data(ii).Group == 0
%      nogo80_resptime_allS = [nogo80_resptime_allS behavior_data(ii).nogo80(1,1:end-2)];
%     else
%      nogo80_resptime_allPFF = [nogo80_resptime_allPFF behavior_data(ii).nogo80(1,1:end-2)]; 
%     end
% 
%     fprintf('The iteration is %d\n', ii)
% end
% 
% figure (1)
% SS80 = histogram(nogo80_resptime_allS,'Normalization','probability');
% SS80 = SS80.Values;
% hold off 
% figure (2)
% PP80 = histogram(nogo80_resptime_allPFF,'Normalization','probability');
% PP80 = PP80.Values;
% hold off
% figure (3)
% PP8 = histogram(go8_resptime_allPFF,'Normalization','probability');
% PP8 = PP8.Values;
% hold off
% figure (4)
% SS8 = histogram(go8_resptime_allS,'Normalization','probability');
% SS8 = SS8.Values;
% close all
% figure (5)
% plot(SS80)
% hold on
% plot(PP80)
% hold on
% plot(SS8)
% hold on
% plot(PP8)
% legend('Saline FA 80%','PFF FA 80%','Saline Hit 80%','PFF Hit 80%','location','Northwest')

%%

function y = Weibull(p,x)

g = 0.5;  %chance performance
% e = (.5)^(1/3);  %threshold performance ( ~80%)
e = (.5)^(1/ 1.9434);  %threshold performance ( ~70%)

%here it is.
k = (-log( (1-e)/(1-g)))^(1/p.b);
y = 1- (1-g)*exp(- (k*x/p.t).^p.b);
end





















