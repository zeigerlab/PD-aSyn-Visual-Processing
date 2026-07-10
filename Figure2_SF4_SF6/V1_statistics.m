
% cd 'N:\Theint Theint\Imaging\Batch_data\DG_updated'
% load('S.mat') 


mpi = 6;
S_all = S;
toDelete = S.depth > -150 & S.mpi  >=4;
S(toDelete,:) = [];
Vtemp = S;


nvals  = cellfun('size',Vtemp.OSI,1);
V = Vtemp(repelem(1:height(Vtemp),nvals),1:5);
V.OSI = vertcat(Vtemp.OSI{:});
V.DSI = vertcat(Vtemp.DSI{:});
V.tunewidth = vertcat(Vtemp.tunewidth{:});
toDelete =  V.mpi  > 6;
V(toDelete,:) = [];

%%
% S = S_all;     % for each animal

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
%% Average per animal
                       
  for ii = 1:2
      for jj = 1:mpi
            gg = sum(repidx_ID{ii,jj} == 0);
            ID_anim {ii,jj} = gptime {ii,jj}.ID (repidx_ID{ii,jj} == 0);
            mpi_anim {ii,jj} = gptime {ii,jj}.mpi (repidx_ID{ii,jj} == 0);
            Group_anim {ii,jj} = gptime {ii,jj}.Group (repidx_ID{ii,jj} == 0);
            total_ncells_anim {ii,jj} = gptime {ii,jj}.total_ncells (repidx_ID{ii,jj} == 0);  
            active_cells_anim {ii,jj} = gptime {ii,jj}.active_cells (repidx_ID{ii,jj} == 0); 
            actcellavg_anim {ii,jj} = gptime {ii,jj}.total_ncells (repidx_ID{ii,jj} == 0);
            DSI_avg_anim {ii,jj} = gptime {ii,jj}.DSI_avg (repidx_ID{ii,jj} == 0);
            OSI_avg_anim {ii,jj} = gptime {ii,jj}.OSI_avg (repidx_ID{ii,jj} == 0);
            tunewidth_anim {ii,jj} = gptime {ii,jj}.mean_tuning_width_above (repidx_ID{ii,jj} == 0);
            ncells_DSIhi_anim {ii,jj} = gptime {ii,jj}.ncells_DSIhi (repidx_ID{ii,jj} == 0);
            ncells_OSIhi_anim {ii,jj} = gptime {ii,jj}.ncells_OSIhi (repidx_ID{ii,jj} == 0);
            ncells_DSIhi6_anim {ii,jj} = gptime {ii,jj}.ncells_DSIhi6 (repidx_ID{ii,jj} == 0);
            ncells_OSIhi6_anim {ii,jj} = gptime {ii,jj}.ncells_OSIhi6 (repidx_ID{ii,jj} == 0);


         
            for kk = 1: max(repidx_ID{ii,jj}) 
                ID_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.ID (repidx_ID{ii,jj} == kk),'omitnan')];
                mpi_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.mpi (repidx_ID{ii,jj} == kk),'omitnan')];
                Group_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.Group (repidx_ID{ii,jj} == kk),'omitnan')];
                total_ncells_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.total_ncells (repidx_ID{ii,jj} == kk),'omitnan')];  
                active_cells_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.active_cells(repidx_ID{ii,jj} == kk),'omitnan')];  
                actcellavg_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.total_ncells(repidx_ID{ii,jj} == kk),'omitnan')];
                DSI_avg_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.DSI_avg(repidx_ID{ii,jj} == kk),'omitnan')];  
                OSI_avg_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.OSI_avg(repidx_ID{ii,jj} == kk),'omitnan')];
                tunewidth_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.mean_tuning_width_above(repidx_ID{ii,jj} == kk),'omitnan')];
                ncells_DSIhi_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.ncells_DSIhi(repidx_ID{ii,jj} == kk),'omitnan')];
                ncells_OSIhi_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.ncells_OSIhi(repidx_ID{ii,jj} == kk),'omitnan')];
                ncells_DSIhi6_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.ncells_DSIhi6(repidx_ID{ii,jj} == kk),'omitnan')];
                ncells_OSIhi6_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.ncells_OSIhi6(repidx_ID{ii,jj} == kk),'omitnan')];
            end
      end     

  end

       A = [];  B = []; C = [];  D = [];  E = [];  
       F = []; G = []; H = []; I = []; J = []; K = []; L = []; M =[];
      for jj = 1:mpi
       A_temp = vertcat(ID_anim{1,jj},ID_anim{2,jj});
       B_temp = vertcat(mpi_anim{1,jj},mpi_anim{2,jj});
       C_temp = vertcat(Group_anim{1,jj},Group_anim{2,jj});
       D_temp = vertcat(total_ncells_anim{1,jj},total_ncells_anim{2,jj});
       E_temp = vertcat(active_cells_anim{1,jj},active_cells_anim{2,jj});
       F_temp = vertcat(actcellavg_anim{1,jj},actcellavg_anim{2,jj}); 
       G_temp = vertcat(DSI_avg_anim{1,jj},DSI_avg_anim{2,jj}); 
       H_temp = vertcat(OSI_avg_anim{1,jj},OSI_avg_anim{2,jj});
       I_temp = vertcat(tunewidth_anim{1,jj},tunewidth_anim{2,jj});
       J_temp = vertcat(ncells_DSIhi_anim{1,jj},ncells_DSIhi_anim{2,jj});
       K_temp = vertcat(ncells_OSIhi_anim{1,jj},ncells_OSIhi_anim{2,jj});
       L_temp = vertcat(ncells_DSIhi6_anim{1,jj},ncells_DSIhi6_anim{2,jj});
       M_temp = vertcat(ncells_OSIhi6_anim{1,jj},ncells_OSIhi6_anim{2,jj});
       A  = [A; A_temp]; B  = [B; B_temp]; C  = [C; C_temp]; D  = [D; D_temp]; E  = [E; E_temp];
       F  = [F; F_temp]; G  = [G; G_temp]; H  = [H; H_temp]; I  = [I; I_temp];  J  = [J; J_temp];
       K  = [K;K_temp]; L  = [L;L_temp]; M  = [M;M_temp];

       T = table(A,B,C,D,E,F,G,H,I,J,K,L,M, 'VariableNames',{'ID', 'mpi', 'Group', 'total_ncells', 'active_cells', 'actcellavg','DSI_avg','OSI_avg','tunewidth','ncells_DSIhi','ncells_OSIhi','ncells_DSIhi6','ncells_OSIhi6'});

      end




 %%   responsive cells
% clearvars -except S_all T V
T.ID = categorical(T.ID);
T.Group = categorical(T.Group);
T.mpi = categorical(T.mpi);
% glme_resp = fitglme(T,'active_cells ~ 1 + Group + mpi  + Group*mpi + (1|ID)' , ...
  %        'Distribution','Binomial','BinomialSize',T.total_ncells,'FitMethod','REMPL')

glme_resp = fitglme(T,'active_cells ~  Group + mpi  + Group*mpi + (1|ID)' , ...
          'Distribution','Binomial','BinomialSize',T.total_ncells,'FitMethod','REMPL')
gaov_respPrct = anova(glme_resp)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(glme_resp.Coefficients(:,6)))



 %% OSI for  responsive cells

% clearvars -except T V
V.ID = categorical(V.ID);
V.Group = categorical(V.Group);
V.mpi = categorical(V.mpi);
lme_OSI = fitlme(V,'OSI ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
aov_OSI = anova(lme_OSI)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_OSI.Coefficients(:,6)))

 %% DSI for  responsive cells

% clearvars -except T V
V.ID = categorical(V.ID);
V.Group = categorical(V.Group);
V.mpi = categorical(V.mpi);
lme_DSI = fitlme(V,'DSI ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
aov_DSI = anova(lme_DSI)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_DSI.Coefficients(:,6)))


 %%   Tuning width
 % clearvars -except T V
V.ID = categorical(V.ID);
V.Group = categorical(V.Group);
V.mpi = categorical(V.mpi);
lme_tunewidth = fitlme(V,'tunewidth ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
aov_tunewidth = anova(lme_tunewidth)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_tunewidth.Coefficients(:,6)))


 %% DSI > 0.5
% clearvars -except S
T.ID = categorical(T.ID);
T.Group = categorical(T.Group);
T.mpi = categorical(T.mpi);
glme_DSIhi = fitglme(T,'ncells_DSIhi ~ Group + mpi  + Group*mpi + (1|ID)', ...
          'Distribution','Binomial','BinomialSize',T.active_cells,'FitMethod','REMPL')
gaov_respPrct = anova(glme_DSIhi)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(glme_DSIhi.Coefficients(:,6)))

 %% OSI > 0.5
% clearvars -except S
T.ID = categorical(T.ID);
T.Group = categorical(T.Group);
T.mpi = categorical(T.mpi);
glme_OSIhi = fitglme(T,'ncells_OSIhi ~ Group + mpi  + Group*mpi + (1|ID)', ...
          'Distribution','Binomial','BinomialSize',T.active_cells,'FitMethod','REMPL')
gaov_respPrct = anova(glme_OSIhi)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(glme_OSIhi.Coefficients(:,6)))

 %% DSI > 0.6
% clearvars -except S
T.ID = categorical(T.ID);
T.Group = categorical(T.Group);
T.mpi = categorical(T.mpi);
glme_DSIhi6 = fitglme(T,'ncells_DSIhi6 ~ Group + mpi  + Group*mpi + (1|ID)', ...
          'Distribution','Binomial','BinomialSize',T.active_cells,'FitMethod','REMPL')
gaov_respPrct = anova(glme_DSIhi6)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(glme_DSIhi6.Coefficients(:,6)))

 %% OSI > 0.6
% clearvars -except S
T.ID = categorical(T.ID);
T.Group = categorical(T.Group);
T.mpi = categorical(T.mpi);
glme_OSIhi6 = fitglme(T,'ncells_OSIhi6 ~ Group + mpi  + Group*mpi + (1|ID)', ...
          'Distribution','Binomial','BinomialSize',T.active_cells,'FitMethod','REMPL')
gaov_respPrct = anova(glme_OSIhi6)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(glme_OSIhi6.Coefficients(:,6)))

%%  #active cells
clearvars -except S_all T V
T.ID = categorical(T.ID);
T.Group = categorical(T.Group);
T.mpi = categorical(T.mpi);
lme_actcells = fitlme(T,'total_ncells ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
aov_actcells = anova(lme_actcells)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_actcells.Coefficients(:,6)))

%% ensemble stability (per ensemble)

% for ii = 1 : length(EvokedData_DG_pairwiseall)    
%   EvokedData_DG_pairwiseall(ii).corr_dice_select = EvokedData_DG_pairwiseall(ii).corr_dice_select'; 
% end

mpi = 6;
E = struct2table(EvokedData_DG_ensemble);
toDelete = E.depth >= -150 & E.mpi  >=4;
E(toDelete,:) = [];
Etemp = E (:,[2:end]);    % for each cell
nvals  = cellfun('size',Etemp.emstab,1);
ET = Etemp(repelem(1:height(Etemp),nvals),1:5);
ET.emstab = vertcat(Etemp.emstab{:});
toDelete =  ET.mpi  > 6;
ET(toDelete,:) = [];


% clearvars -except T V S
ET.ID = categorical(ET.ID);
ET.Group = categorical(ET.Group);
ET.mpi = categorical(ET.mpi);
lme_emstab = fitlme(ET,'emstab ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
aov_emstab = anova(lme_emstab)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_emstab.Coefficients(:,6)))


%% pairwise synchronicity
mpi = 6;
P = struct2table(EvokedData_DG_pairwiseall);
toDelete = P.depth >= -150 & P.mpi  >=4;
P(toDelete,:) = [];
Ptemp = P (:,[2:end]);    % for each cell
nvals  = cellfun('size',Ptemp.corr_dice_select,1);
PT = Ptemp(repelem(1:height(Ptemp),nvals),1:5);
PT.corr_dice = vertcat(Ptemp.corr_dice_select{:});
toDelete =  PT.mpi  > 6;
PT(toDelete,:) = [];


PT.ID = categorical(PT.ID);
PT.Group = categorical(PT.Group);
PT.mpi = categorical(PT.mpi);
lme_emstab = fitlme(PT,'corr_dice ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
aov_emstab = anova(lme_emstab)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_emstab.Coefficients(:,6)))


 %% DSI for of responsive cells
% 
% clearvars -except S
% S.ID = categorical(S.ID);
% S.Group = categorical(S.Group);
% S.mpi = categorical(S.mpi);
% lme_DSI = fitlme(S,'DSI_avg ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
% aov_DSI = anova(lme_DSI)
% [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_DSI.Coefficients(:,6)))
% 
% 
% 
% 
%  %% Amplitude of stimulus-evoked traces
% clearvars -except S
% S.ID = categorical(S.ID);
% S.Group = categorical(S.Group);
% S.mpi = categorical(S.mpi);
% lme_stim_amp = fitlme(S,'stim_amp_avg ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
% aov_stim_amp = anova(lme_stim_amp)
% [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_stim_amp.Coefficients(:,6)))
% 
% 
% 
% %% AUC of stimulus-evoked traces
% 
% clearvars -except S
% S.ID = categorical(S.ID);
% S.Group = categorical(S.Group);
% S.mpi = categorical(S.mpi);
% lme_stim_AUC = fitlme(S,'Stim_AUC_avg ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
% aov_stim_AUC = anova(lme_stim_AUC)
% [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_stim_AUC.Coefficients(:,6)))
% 
% %%  transient freq of stimulus-evoked traces
% 
% clearvars -except S
% S.ID = categorical(S.ID);
% S.Group = categorical(S.Group);
% S.mpi = categorical(S.mpi);
% lme_stim_trans = fitlme(S,'stim_trans_avg ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
% aov_stim_trans = anova(lme_stim_trans)
% [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_stim_trans.Coefficients(:,6)))
% 
% 
% %%






