%  load ('Evokeddata_DG.mat')
%  jj = 195; 
%  percentile = 0.01;
% 
%  stimstarts = EvokedData_DG(jj).stimstarts;
%  stimends_mod = stimstarts + 15;
% 
%  remv = find (EvokedData_DG(jj).activeROI==0);
%  active_traces = EvokedData_DG(jj).signal_traces;
% active_traces(:, remv)=[];         %active cells after using S2P and Determine_Active_ROIs
% 
% allROI_signal = active_traces';
% 
%  j = 1; k = 1;
%  for i = 1: size(EvokedData_DG(jj).signal_percentile,2)
%      try
%      EvokedData_DG(jj).signal_percentile = cell2mat (EvokedData_DG(jj).signal_percentile);
%      catch
%      EvokedData_DG(jj).signal_percentile =EvokedData_DG(jj).signal_percentile;
%      end
%      if EvokedData_DG(jj).signal_percentile (i) <= percentile
%          lockedROI (j,:) = allROI_signal (i,:);
%          lockedperc (j) = EvokedData_DG(jj).signal_percentile (i);
%          j = j + 1;
% 
% %      elseif EvokedData_DG(jj).signal_percentile (i) > percentile
%      elseif isnan(EvokedData_DG(jj).signal_percentile (i))    
%          unlockedROI (k,:) = allROI_signal (i,:);
%          unlockedperc (k) = EvokedData_DG(jj).signal_percentile (i);
%          k = k+1;
%      end
%  end
% 
% 
% % to determine the start of each direction in each trial
% trial_stimstarts = cell (1,4); 
%  j = [1,9,17,25];
% for i = 1: numel(j)  % for 4 trials  
%     trial_stimstarts{1,i} = stimstarts (j(i):j(i)+7);      
% end  
% 
%  trial_stimends_mod = cellfun(@(x) x + 15, trial_stimstarts, 'UniformOutput', false);
% 
% 
%  trial_stimstarts_ext = cellfun(@(x) x - 10, trial_stimstarts, 'UniformOutput', false);
%  trial_stimends_mod_ext = cellfun(@(x) x + 25, trial_stimstarts, 'UniformOutput', false);
% 
% % to determine the end of each direction in each trial
% % trial_stimends = cell (1,4); 
% %  j = [1,9,17,25];
% % for i = 1: numel(j)  % for 4 trials  
% %     trial_stimends_mod{1,i} = stimends_mod (j(i):j(i)+7);  
% % end
% 
% 
% 
% %in 2D, row is trial and column is orientation. 
% 
% trial_trace = {}; counter = 1;
% for k = 1:size (lockedROI,1)  % # responsive cells
%         for i = 1: 4   % #trials    
%                 for j = 1:8   % #orientations
%                 trial_trace {i,j,k} = lockedROI (k,trial_stimstarts{i}(j): trial_stimends_mod {i}(j));  
%                 end
%         end
% end
% 
% trial_trace_ext = {}; counter = 1;
% for k = 1:size (lockedROI,1)  % # responsive cells
%         for i = 1: 4   % #trials    
%                 for j = 1:8   % #orientations
%                 trial_trace_ext {i,j,k} = lockedROI (k,trial_stimstarts_ext{i}(j): trial_stimends_mod_ext {i}(j));  
%                 end
%         end
% end
% 
% 
% % find the average signals over 4 trials
% for i = 1: size (trial_trace_ext, 3) 
%     for j = 1 : 8
%     frames_stimuli  = size (trial_trace_ext{1,j},2);
%     trial_trace_avg (:,:,i) = mat2tiles (mean (cell2mat(trial_trace_ext (:,:,i)),1) ,[1, frames_stimuli ]);
%     end
% end 
% 
% % Reset the trial start and end time to zero 
% trial_stimstarts_reset = cell2mat(trial_stimstarts) - min(cell2mat(trial_stimstarts));
% trial_stimstarts_reset = trial_stimstarts_reset';
% trial_stimends_mod_reset = cell2mat(trial_stimends_mod) - min(cell2mat(trial_stimstarts));
% trial_stimends_mod_reset = trial_stimends_mod_reset';
% 
% trial_stimstarts_resetext = cell2mat(trial_stimstarts_ext) - min(cell2mat(trial_stimstarts_ext));
% trial_stimstarts_resetext = trial_stimstarts_resetext';
% trial_stimends_mod_resetext = cell2mat(trial_stimends_mod_ext) - min(cell2mat(trial_stimstarts_ext));
% trial_stimends_mod_resetext = trial_stimends_mod_resetext';



   
                                                  % plot trace of responsive cell
 
load ('plot_trace.mat')


  i = 4;  % ROI number to be plotted
  p(i) = figure (i);
  for j = 1:5  % 4trials + average trial
      subplot(5,1,j)
      for k = 1:8    % direction
          if j ~= 5
              plot (trial_stimstarts_resetext(j,k):trial_stimends_mod_resetext(j,k), trial_trace_ext{j,k,i},'-k','linewidth',1.5)
              a = trial_stimstarts_reset(1,k) ;
              c = min(cell2mat(trial_trace(j,:,i)));  d = max(cell2mat(trial_trace(j,:,i)));
              patch([a+10 a+20 a+20 a+10], [c c d d],[.75 .75 .75],'FaceAlpha',0.4, 'Edgecolor', 'none')      
              ylim([-10 30])
              hold on

          elseif j == 5

              plot (trial_stimstarts_resetext(1,k):trial_stimends_mod_resetext(1,k), trial_trace_avg{1,k,i},'-k','linewidth',1.5)
              a = trial_stimstarts_reset(1,k) ;
              b = min(cell2mat(trial_trace_avg(:,:,i)));  c = max(cell2mat(trial_trace_avg(:,:,i)));
              patch([a+10 a+20 a+20 a+10], [b b c c],[.75 .75 .75],'FaceAlpha',0.4, 'Edgecolor', 'none')
              ylabel('Average')
              xlabel('# frames')
              ylim([-10 30])
              hold on
          end
          hold on
      end
     
      box off
    
  end
  title (sprintf('session: %d, cell: %d, signal percentile is %0.3f.', jj, i, lockedperc(i)))