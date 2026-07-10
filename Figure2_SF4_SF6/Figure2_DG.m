% load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure2\visualevokedtb.mat')


S = VE;

mpi = 6;
gptime = cell (2, mpi);   % ROW 1 IS PFF; ROW 2 IS SALINE

for ii = 1: mpi           
    idx = (S.mpi == ii & S.Group == 1);            
    gptime {1,ii} = S(idx,:); 
    idx = (S.mpi == ii & S.Group == 0);
    gptime {2,ii} = S(idx,:);
end

rep_ID = cell (2, mpi);
uniq_ID = cell (2, mpi);
repidx_ID = cell (2, mpi);
uniqidx_ID = cell (2, mpi);
for ii = 1:2
    for jj = 1: mpi
    ID = unique (gptime {ii,jj}.ID);
    rep_ID {ii,jj} = ID (1<histc(gptime {ii,jj}.ID,ID));
    [~,repidx ] = ismember (gptime {ii,jj}.ID, rep_ID {ii,jj});
    repidx_ID{ii,jj} = repidx; 
    end
end

%Average for whole grouptime                                                    
  for ii = 1:2
      for jj = 1:mpi
          perc_resp {ii,jj} = mean (gptime {ii,jj}.percent_responsive,'omitnan');
          % tune_wid {ii,jj} = mean (gptime {ii,jj}.mean_tuning_width_above,'omitnan');
          % OSI_hi {ii,jj} = mean (gptime {ii,jj}.OSI_highly,'omitnan');
          % DSI_hi {ii,jj} = mean (gptime {ii,jj}.DSI_highly,'omitnan');
          OSI_hi6 {ii,jj} = mean (gptime {ii,jj}.OSI_highly6,'omitnan');
          DSI_hi6 {ii,jj} = mean (gptime {ii,jj}.DSI_highly6,'omitnan');
          OSI_prop {ii,jj} = mean (gptime {ii,jj}.OSI_prop,'omitnan');
          DSI_prop {ii,jj} = mean (gptime {ii,jj}.DSI_prop,'omitnan');
          OSI_avg {ii,jj} = mean (gptime {ii,jj}.OSI_avg,'omitnan');
          DSI_avg {ii,jj} = mean (gptime {ii,jj}.DSI_avg,'omitnan');
          % actcells_um {ii,jj} = mean (gptime {ii,jj}.actcells_um,'omitnan');
          corr_diceall {ii,jj} = mean (gptime {ii,jj}.corr_dice_bs_vid,'omitnan');
          emstab {ii,jj} = mean (gptime {ii,jj}.emstab_vid,'omitnan');
          % totalcellsrecorded_FOV {ii,jj} = mean (gptime {ii,jj}.totalcellsrecorded_FOV,'omitnan');
          % totalcellsrecorded_FOVall {ii,jj} = sum (gptime {ii,jj}.totalcellsrecorded_FOV,'omitnan');
      end 
  end

  % Average per animal
                       
  for ii = 1:2
      for jj = 1:mpi
            gg = sum(repidx_ID{ii,jj} == 0);
            perc_resp_anim {ii,jj} = gptime {ii,jj}.percent_responsive (repidx_ID{ii,jj} == 0);  
            % tune_wid_anim {ii,jj} = gptime {ii,jj}.mean_tuning_width_above (repidx_ID{ii,jj} == 0);  
            % OSI_hi_anim {ii,jj} = gptime {ii,jj}.OSI_highly (repidx_ID{ii,jj} == 0);  
            % DSI_hi_anim {ii,jj} = gptime {ii,jj}.DSI_highly (repidx_ID{ii,jj} == 0); 
            OSI_hi6_anim {ii,jj} = gptime {ii,jj}.OSI_highly6 (repidx_ID{ii,jj} == 0);  
            DSI_hi6_anim {ii,jj} = gptime {ii,jj}.DSI_highly6 (repidx_ID{ii,jj} == 0); 
            OSI_prop_anim {ii,jj} = gptime {ii,jj}.OSI_prop (repidx_ID{ii,jj} == 0,:);  
            DSI_prop_anim {ii,jj} = gptime {ii,jj}.DSI_prop (repidx_ID{ii,jj} == 0,:); 
            OSI_avg_anim {ii,jj} = gptime {ii,jj}.OSI_avg (repidx_ID{ii,jj} == 0);
            DSI_avg_anim {ii,jj} = gptime {ii,jj}.DSI_avg (repidx_ID{ii,jj} == 0);
            % actcells_um_anim {ii,jj} = gptime {ii,jj}.actcells_um (repidx_ID{ii,jj} == 0);
            % corr_diceall_anim {ii,jj} = gptime {ii,jj}.corr_dice_bs_vid (repidx_ID{ii,jj} == 0);
            emstab_anim {ii,jj} = gptime {ii,jj}.emstab_vid (repidx_ID{ii,jj} == 0);         
            for kk = 1: max(repidx_ID{ii,jj}) 
                perc_resp_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.percent_responsive (repidx_ID{ii,jj} == kk),'omitnan')];  
                % tune_wid_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.mean_tuning_width_above (repidx_ID{ii,jj} == kk),'omitnan')];
                % OSI_hi_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.OSI_highly (repidx_ID{ii,jj} == kk),'omitnan')];
                % DSI_hi_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.DSI_highly (repidx_ID{ii,jj} == kk),'omitnan')];
                OSI_hi6_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.OSI_highly6 (repidx_ID{ii,jj} == kk),'omitnan')];
                DSI_hi6_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.DSI_highly6 (repidx_ID{ii,jj} == kk),'omitnan')];
                OSI_prop_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.OSI_prop (repidx_ID{ii,jj} == kk,:),'omitnan')];
                DSI_prop_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.DSI_prop (repidx_ID{ii,jj} == kk,:),'omitnan')];
                OSI_avg_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.OSI_avg (repidx_ID{ii,jj} == kk),'omitnan')];
                DSI_avg_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.DSI_avg (repidx_ID{ii,jj} == kk),'omitnan')];
                % actcells_um_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.actcells_um (repidx_ID{ii,jj} == kk),'omitnan')];
                corr_diceall_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.corr_dice_bs_vid (repidx_ID{ii,jj} == kk),'omitnan')];
                emstab_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.emstab_vid (repidx_ID{ii,jj} == kk),'omitnan')];
            end
      end 
  end


  %  SEM

  for ii = 1:2
      for jj = 1:mpi
        perc_resp_sem {ii,jj} = std(perc_resp_anim{ii,jj},'omitnan')/sqrt(length(perc_resp_anim{ii,jj}));
        % tune_wid_sem {ii,jj} = std(tune_wid_anim{ii,jj},'omitnan')/sqrt(length(tune_wid_anim{ii,jj}));
        % OSI_hi_sem {ii,jj} = std(OSI_hi_anim{ii,jj},'omitnan')/sqrt(length(OSI_hi_anim{ii,jj}));
        % DSI_hi_sem {ii,jj} = std(DSI_hi_anim{ii,jj},'omitnan')/sqrt(length(DSI_hi_anim{ii,jj}));
        OSI_hi6_sem {ii,jj} = std(OSI_hi6_anim{ii,jj},'omitnan')/sqrt(length(OSI_hi6_anim{ii,jj}));
        DSI_hi6_sem {ii,jj} = std(DSI_hi6_anim{ii,jj},'omitnan')/sqrt(length(DSI_hi6_anim{ii,jj}));
        OSI_prop_sem {ii,jj} = std(OSI_prop_anim{ii,jj},'omitnan')/sqrt(length(OSI_prop_anim{ii,jj}));
        DSI_prop_sem {ii,jj} = std(DSI_prop_anim{ii,jj},'omitnan')/sqrt(length(DSI_prop_anim{ii,jj}));
        OSI_avg_sem {ii,jj} = std(OSI_avg_anim{ii,jj},'omitnan')/sqrt(length(OSI_avg_anim{ii,jj}));
        DSI_avg_sem {ii,jj} = std(DSI_avg_anim{ii,jj},'omitnan')/sqrt(length(DSI_avg_anim{ii,jj}));
        % actcells_um_sem {ii,jj} = std(actcells_um_anim{ii,jj},'omitnan')/sqrt(length(actcells_um_anim{ii,jj}));
        corr_diceall_sem {ii,jj} = std(corr_diceall_anim{ii,jj},'omitnan')/sqrt(length(corr_diceall_anim{ii,jj}));
        emstab_sem {ii,jj} = std(emstab_anim{ii,jj},'omitnan')/sqrt(length(emstab_anim{ii,jj}));
        % Mouse_num_DG (ii,jj) = length(perc_resp_anim{ii,jj});
      end 
  end 


  %% plot graph
figure (1);
plotgraph  (perc_resp,perc_resp_sem, mpi,'%responsive cells');
ylim([0 60])


% figure (2); 
% close all
% plotgraph  (tune_wid,tune_wid_sem, mpi,'Tuning Width (degrees)');
% ylim([0 60])


figure (3);
plotgraph  (DSI_avg,DSI_avg_sem, mpi,'DSI');
ylim([0 0.6])


% figure (4); close all
% plotgraph  (DSI_hi,DSI_hi_sem, mpi,'% cells (DSI > 0.5)');
% ylim([0 60])


figure (5); close all
plotgraph  (corr_diceall,corr_diceall_sem, mpi,'Pairwise Synchronicity');
ylim([0 0.35])


figure (6); 
plotgraph  (emstab,emstab_sem, mpi,'Ensemble Stability');
ylim([0 0.5])


figure (7);
plotgraph  (OSI_avg,OSI_avg_sem, mpi,'OSI');
ylim([0 0.6])

 
% figure (8); 
% plotgraph  (OSI_hi,OSI_hi_sem, mpi,'% cells (OSI > 0.5)');
% ylim([0 60])


figure (9);
plotgraph  (OSI_hi6,OSI_hi6_sem, mpi,'% cells (OSI > 0.6)');
ylim([0 60])


figure (10); 
plotgraph  (DSI_hi6,DSI_hi6_sem, mpi,'% cells (DSI > 0.6)');
ylim([0 60])


timept = 1;
figure (11); 
plotproportion_OSI  (OSI_prop,OSI_prop_sem, timept);
ylim([0 40])
title(['OSI ' num2str(timept)]);


figure (12); 
plotproportion_DSI  (DSI_prop,DSI_prop_sem, timept);
ylim([0 50])
title(['DSI ' num2str(timept)]);
                                                      



function plotproportion_OSI (average, sem, timept)
% average = OSI_prop;
% sem = OSI_prop_sem;
average = cell2mat (average(:,timept));
sem = cell2mat(sem(:,timept));

errorbar (average(1,:),sem(1,:),'-r','LineWidth',1.5)
hold on
errorbar (average(2,:),sem(2,:),'-k','LineWidth',1.5)

xticks(1:5)
xticklabels({'0.2','0.4','0.6','0.8','1'})
ax = gca;
yl = ylim(ax); 
axis(ax, 'tight')
ylim(ax, yl)

xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
a = strcat ('PFF', '(',num2str(timept),'mpi)');
b = strcat ('Saline', '(',num2str(timept),'mpi)');
legend(a,b,'Location','northeast')
xlabel ('OSI')
ylabel ('% Responsive Cells')
% title('% Responsive Cells','FontSize',16)
end

function plotproportion_DSI (average, sem, timept)
% average = OSI_prop;
% sem = OSI_prop_sem;
average = cell2mat (average(:,timept));
sem = cell2mat(sem(:,timept));

errorbar (average(1,:),sem(1,:),'-r','LineWidth',1.5)
hold on
errorbar (average(2,:),sem(2,:),'-k','LineWidth',1.5)

xticks(1:5)
xticklabels({'0.2','0.4','0.6','0.8','1'})
ax = gca;
yl = ylim(ax); 
axis(ax, 'tight')
ylim(ax, yl)

xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
a = strcat ('PFF', '(',num2str(timept),'mpi)');
b = strcat ('Saline', '(',num2str(timept),'mpi)');
legend(a,b,'Location','northeast')
xlabel ('DSI')
ylabel ('% Responsive Cells')
% title('% Responsive Cells','FontSize',16)
end
