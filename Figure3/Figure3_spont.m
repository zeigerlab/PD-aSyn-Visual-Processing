load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure3\sponttb.mat')

S = SP;
mpi = 6;

gptime = cell (2, mpi);   % ROW 1 IS PFF; ROW 2 IS SALINE

for ii = 1: mpi           
    idx = (S.mpi == ii & S.Group == 1);            
    gptime {1,ii} = S(idx,:); 
    idx = (S.mpi == ii & S.Group == 0);
    gptime {2,ii} = S(idx,:);
end


%%

 % find imaging sessions from the same animal

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

 %% Average for whole grouptime                                                    
  for ii = 1:2
      for jj = 1:mpi
          pair_corr {ii,jj} = mean (gptime {ii,jj}.pair_correlated,'omitnan');
          spont_amp {ii,jj} = mean (gptime {ii,jj}.peak_amp_avg,'omitnan');
          spont_trans {ii,jj} = mean (gptime {ii,jj}.trans_spont_avg,'omitnan');
          spont_AUC {ii,jj} = mean (gptime {ii,jj}.AUC_spont_avg,'omitnan');
          spont_Rreal_avg {ii,jj} = mean (gptime{ii,jj}.Rreal_vid,'omitnan');
          spont_Rshuff_avg {ii,jj} = mean (gptime{ii,jj}.Rshuff_vid,'omitnan');
          spont_pop_coup {ii,jj} = mean (gptime{ii,jj}.pop_coup_vid,'omitnan');
          spont_actcells {ii,jj} = mean (gptime {ii,jj}.actcells,'omitnan');          
          corr_diceall {ii,jj} = mean (gptime {ii,jj}.corr_dice_bs_vid,'omitnan');
          emstab {ii,jj} = mean (gptime {ii,jj}.emstab_vid,'omitnan');
          totalcellsrecorded_FOV {ii,jj} = mean (gptime {ii,jj}.totalcellsrecorded_FOV,'omitnan');
          totalcellsrecorded_FOVall {ii,jj} = sum (gptime {ii,jj}.totalcellsrecorded_FOV,'omitnan');
      end 
  end

    %% Average per animal
                       
  for ii = 1:2
      for jj = 1:mpi
            gg = sum(repidx_ID{ii,jj} == 0);
            pair_corr_anim {ii,jj} = gptime {ii,jj}.pair_correlated (repidx_ID{ii,jj} == 0);  
            spont_amp_anim {ii,jj} = gptime {ii,jj}.peak_amp_avg (repidx_ID{ii,jj} == 0);  
            spont_trans_anim {ii,jj} = gptime {ii,jj}.trans_spont_avg (repidx_ID{ii,jj} == 0);  
            spont_AUC_anim {ii,jj} = gptime {ii,jj}.AUC_spont_avg (repidx_ID{ii,jj} == 0); 
            spont_Rreal_anim {ii,jj} = gptime {ii,jj}.Rreal_vid (repidx_ID{ii,jj} == 0); 
            spont_Rshuff_anim {ii,jj} = gptime {ii,jj}.Rshuff_vid (repidx_ID{ii,jj} == 0);
            spont_pop_coup_anim {ii,jj} = gptime {ii,jj}.pop_coup_vid (repidx_ID{ii,jj} == 0); 
            spont_actcells_anim {ii,jj} = gptime {ii,jj}.actcells (repidx_ID{ii,jj} == 0); 
            corr_diceall_anim {ii,jj} = gptime {ii,jj}.corr_dice_bs_vid (repidx_ID{ii,jj} == 0); 
            emstab_anim {ii,jj} = gptime {ii,jj}.emstab_vid (repidx_ID{ii,jj} == 0);

         
            for kk = 1: max(repidx_ID{ii,jj}) 
                pair_corr_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.pair_correlated (repidx_ID{ii,jj} == kk),'omitnan')];  
                spont_amp_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.peak_amp_avg (repidx_ID{ii,jj} == kk),'omitnan')];
                spont_trans_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.trans_spont_avg (repidx_ID{ii,jj} == kk),'omitnan')];
                spont_AUC_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.AUC_spont_avg (repidx_ID{ii,jj} == kk),'omitnan')];
                spont_Rreal_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.Rreal_vid (repidx_ID{ii,jj} == kk),'omitnan')];
                spont_Rshuff_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.Rshuff_vid (repidx_ID{ii,jj} == kk),'omitnan')];
                spont_pop_coup_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.pop_coup_vid (repidx_ID{ii,jj} == kk),'omitnan')];
                spont_actcells_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.actcells(repidx_ID{ii,jj} == kk),'omitnan')];
                corr_diceall_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.corr_dice_bs_vid (repidx_ID{ii,jj} == kk),'omitnan')];
                emstab_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.emstab_vid (repidx_ID{ii,jj} == kk),'omitnan')];

            end
      end 
  end

   %%  SEM

  for ii = 1:2
      for jj = 1:mpi
        pair_corr_sem {ii,jj} = std(pair_corr_anim{ii,jj})/sqrt(length(pair_corr_anim{ii,jj}));
        spont_amp_sem {ii,jj} = std(spont_amp_anim{ii,jj})/sqrt(length(spont_amp_anim{ii,jj}));
        spont_trans_sem {ii,jj} = std(spont_trans_anim{ii,jj})/sqrt(length(spont_trans_anim{ii,jj}));
        spont_AUC_sem {ii,jj} = std(spont_AUC_anim{ii,jj})/sqrt(length(spont_AUC_anim{ii,jj}));
        spont_Rreal_sem {ii,jj} = std(spont_Rreal_anim{ii,jj})/sqrt(length(spont_Rreal_anim{ii,jj}));
        spont_Rshuff_sem {ii,jj} = std(spont_Rshuff_anim{ii,jj})/sqrt(length(spont_Rshuff_anim{ii,jj}));
        spont_pop_coup_sem {ii,jj} = std(spont_pop_coup_anim{ii,jj})/sqrt(length(spont_pop_coup_anim{ii,jj}));
        spont_actcells_sem {ii,jj} = std(spont_actcells_anim{ii,jj})/sqrt(length(spont_actcells_anim{ii,jj}));
        corr_diceall_sem {ii,jj} = std(corr_diceall_anim{ii,jj},'omitnan')/sqrt(length(corr_diceall_anim{ii,jj}));
        emstab_sem {ii,jj} = std(emstab_anim{ii,jj},'omitnan')/sqrt(length(emstab_anim{ii,jj}));
        Mouse_num_spont (ii,jj) = length(pair_corr_anim{ii,jj});
      end 
  end 

  figure (1);
plotgraph  (pair_corr,pair_corr_sem, mpi,'% correlated pairs');
ylim([0 100])


figure (2); 
plotgraph  (spont_amp,spont_amp_sem, mpi,'Amplitude(z-score)');
ylim([0 8])

figure (3); 
plotgraph  (spont_trans,spont_trans_sem, mpi,'Transient frequency per min');
ylim([0 10])


figure (4); 
plotgraph  (spont_AUC,spont_AUC_sem, mpi,'AUC*seconds');
ylim([0 250])


figure (9)
plotgraph  (emstab,emstab_sem, mpi,'Ensemble Stability');
ylim([0 0.5])
