
% cd 'N:\Theint Theint\Imaging\Batch_data\Spontaneous'
% load('S.mat')

mpi = 6;

S_all = S;

Vtemp = S_all (:,[2:end]);    % for each cell
nvals  = cellfun('size',Vtemp.peak_amp,1);
V = Vtemp(repelem(1:height(Vtemp),nvals),1:5);
V.peak_amp = vertcat(Vtemp.peak_amp{:});
V.trans_spont = vertcat(Vtemp.trans_spont{:});
V.AUC_spont = vertcat(Vtemp.AUC_spont{:});

V.pop_coup = vertcat(Vtemp.pop_coup{:});
toDelete =  V.mpi  > 6;
V(toDelete,:) = [];
%%
S = S_all (:,[2:end]);     % for each animal

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
            paircorr_anim {ii,jj} = gptime {ii,jj}.pair_correlated (repidx_ID{ii,jj} == 0);
            peakampavg_anim {ii,jj} = gptime {ii,jj}.peak_amp_avg (repidx_ID{ii,jj} == 0);
            transspontavg_anim {ii,jj} = gptime {ii,jj}.trans_spont_avg (repidx_ID{ii,jj} == 0);
            AUCspontavg_anim {ii,jj} = gptime {ii,jj}.AUC_spont_avg (repidx_ID{ii,jj} == 0);
            totalnpairsavg_anim {ii,jj} = gptime {ii,jj}.total_npairs (repidx_ID{ii,jj} == 0);
            corrnpairsavg_anim {ii,jj} = gptime {ii,jj}.correlated_npairs (repidx_ID{ii,jj} == 0);

         
            for kk = 1: max(repidx_ID{ii,jj}) 
                ID_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.ID (repidx_ID{ii,jj} == kk),'omitnan')];
                mpi_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.mpi (repidx_ID{ii,jj} == kk),'omitnan')];
                Group_anim {ii,jj}(gg+kk,:) = [mean(gptime {ii,jj}.Group (repidx_ID{ii,jj} == kk),'omitnan')];
                paircorr_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.pair_correlated(repidx_ID{ii,jj} == kk),'omitnan')];  
                peakampavg_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.peak_amp_avg(repidx_ID{ii,jj} == kk),'omitnan')]; 
                transspontavg_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.trans_spont_avg(repidx_ID{ii,jj} == kk),'omitnan')]; 
                AUCspontavg_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.AUC_spont_avg(repidx_ID{ii,jj} == kk),'omitnan')]; 
                totalnpairsavg_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.total_npairs(repidx_ID{ii,jj} == kk),'omitnan')]; 
                corrnpairsavg_anim {ii,jj}(gg+kk,:) = [sum(gptime {ii,jj}.correlated_npairs(repidx_ID{ii,jj} == kk),'omitnan')]; 
            end
      end     

  end
%%
       A = [];  B = []; C = [];  D = [];  E = [];  
       F = []; G = []; H = []; I = [];
      for jj = 1:mpi
       A_temp = vertcat(ID_anim{1,jj},ID_anim{2,jj});
       B_temp = vertcat(mpi_anim{1,jj},mpi_anim{2,jj});
       C_temp = vertcat(Group_anim{1,jj},Group_anim{2,jj});
       D_temp = vertcat(paircorr_anim{1,jj},paircorr_anim{2,jj});  
       E_temp = vertcat(peakampavg_anim{1,jj},peakampavg_anim{2,jj}); 
       F_temp = vertcat(transspontavg_anim{1,jj},transspontavg_anim{2,jj}); 
       G_temp = vertcat(AUCspontavg_anim{1,jj},AUCspontavg_anim{2,jj}); 
       H_temp = vertcat(totalnpairsavg_anim{1,jj},totalnpairsavg_anim{2,jj}); 
       I_temp = vertcat(corrnpairsavg_anim{1,jj},corrnpairsavg_anim{2,jj}); 
       A  = [A; A_temp]; B  = [B; B_temp]; C  = [C; C_temp]; D  = [D; D_temp]; E  = [E; E_temp];
       F  = [F; F_temp]; G  = [G; G_temp]; H  = [H; H_temp]; I  = [I; I_temp];
       T = table(A, B, C, D, E, F, G, H, I,'VariableNames',{'ID', 'mpi', 'Group', 'pair_correlated', 'peak_amp_avg', ...
           'trans_spont_avg', 'AUC_spont_avg','total_npairs', 'correlated_npairs'});
      end

      
 %% percentage correlated pair   (LME)

% clearvars -except T V S
T.ID = categorical(T.ID);
T.Group = categorical(T.Group);
T.mpi = categorical(T.mpi);
lme_corrp = fitlme(T,'pair_correlated ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
gaov_corrp = anova(lme_corrp)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_corrp.Coefficients(:,6)))


 %% AUC  (per cell)

% clearvars -except T V S
V.ID = categorical(V.ID);
V.Group = categorical(V.Group);
V.mpi = categorical(V.mpi);
lme_AUC_spont = fitlme(V,'AUC_spont ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
aov_AUC_spont = anova(lme_AUC_spont)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_AUC_spont.Coefficients(:,6)))


 %% Peak amp  (per cell)

% clearvars -except T V S
V.ID = categorical(V.ID);
V.Group = categorical(V.Group);
V.mpi = categorical(V.mpi);
lme_peak_amp = fitlme(V,'peak_amp ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
aov_peak_amp = anova(lme_peak_amp)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_peak_amp.Coefficients(:,6)))

 %% transient   (per cell)

% clearvars -except T V S
V.ID = categorical(V.ID);
V.Group = categorical(V.Group);
V.mpi = categorical(V.mpi);
lme_trans_spont = fitlme(V,'trans_spont ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
aov_trans_spont = anova(lme_trans_spont)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_trans_spont.Coefficients(:,6)))




%% ensemble stability (per ensemble)
mpi = 6;
E = struct2table(EvokedData_Spont_ensemble);
toDelete = E.depth >= -150 & E.mpi  >=4;
E(toDelete,:) = [];
Etemp = E (:,[2:6, end-1]);    % for each cell
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
P = struct2table(EvokedData_Spont_pairwiseall);
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