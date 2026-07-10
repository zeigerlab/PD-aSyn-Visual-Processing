%% plot d prime in the 1mpi training (line graph)
n = 15;
saline {1,1} = [-0.02 0.70 0.62 1.00 1.16 2.34 2.87 3.01]; saline{1,1}(end+1:n) = nan; 
saline {2,1} = [0.22 0.11 0.03 1.62 1.07 1.03 1.50 1.91 2.03]; saline{2,1}(end+1:n) = nan; 
saline {3,1} = [-0.14 -0.03 0.07 0.10 0.75 1.34 1.60 1.80 1.22 1.90 1.89]; saline{3,1}(end+1:n) = nan; 
saline {4,1} = [0.36 0.03 0.04 0.76 0.91 2.12 1.63 1.71 2.14]; saline{4,1}(end+1:n) = nan;
saline {5,1} = [0.98 1.87 2.09 2.29]; saline{5,1}(end+1:n) = nan;
saline {6,1} = [0.10 0.10 0.55 1.77 1.92 2.24]; saline{6,1}(end+1:n) = nan;
saline {7,1} = [1.15 0.41 0.64 0.61 0.68 0.74 1.31 0.88 1.63 1.85]; saline{7,1}(end+1:n) = nan;
saline {8,1} = [0.57 0.84 1.49 1.08 1.74 2.23]; saline{8,1}(end+1:n) = nan;
saline {9,1} = [0.32 0.73 1.29 1.87 1.88]; saline{9,1}(end+1:n) = nan;
saline {10,1} = [0.25 0.50 1.48 0.63 1.17 0.69 1.84 2.00]; saline{10,1}(end+1:n) = nan;
saline {11,1} = [-0.12 0.06 0.24 0.35 -0.28 1.35 1.88]; saline{11,1}(end+1:n) = nan;
saline {12,1} = [0.41 1.02 1.66 2.19 1.80]; saline{12,1}(end+1:n) = nan;
salineall = cell2mat(saline);
saline_avg = mean(salineall,[1],'omitnan');


figure (1)
grayColor = [.7 .7 .7];
for ii = 1:length(saline)
plot (saline{ii,1},'Color', grayColor,'LineWidth',1.0)
hold on 
end
plot (saline_avg,'Color', grayColor,'LineWidth',4.0)

yline(1.80,'LineWidth', 2,'Color','k','LineStyle','--')
ylabel('d prime', 'FontSize',20)
xlabel('# training days', 'FontSize',20)
ax = gca;
axis(ax, 'tight')
xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
xlim([0 15])
xticks([0:15])
ylim([-0.5 3.5])
hold on

%PFF

n = 15;
PFF {1,1} = [-0.23 -0.29 -0.22 0.25 0.81 0.43 0.38 1.35 1.86 2.43]; PFF{1,1}(end+1:n) = nan; 
PFF {2,1} = [-0.43 -0.06 0.52 1.21 1.33 1.86 2.02]; PFF{2,1}(end+1:n) = nan; 
PFF {3,1} = [0.23 0.21 0.70 0.78 0.80 1.10 1.31 1.37 1.62 2.89 3.33 2.77]; PFF{3,1}(end+1:n) = nan; 
PFF {4,1} = [0.37 0.02 0.11 0.43 0.93 1.13 2.03 2.10]; PFF{4,1}(end+1:n) = nan;
PFF {5,1} = [0.09 -0.24 -0.14 0.58 0.28 0.04 0.92 1.55 1.43 2.25 2.39]; PFF{5,1}(end+1:n) = nan;
PFF {6,1} = [-0.05 -0.31 0.34 0.43 0.97 1.16 1.66 1.68 2.20 1.91]; PFF{6,1}(end+1:n) = nan;
PFF {7,1} = [0.07 -0.06 0.37 0.19 0.59 1.63 1.10 1.22]; PFF{7,1}(end+1:n) = nan;
PFF {8,1} = [0.81 1.70 1.63 1.10 1.88]; PFF{8,1}(end+1:n) = nan;
PFF {9,1} = [0.28 0.63 0.26 0.47 1.55 1.37 1.90 1.96]; PFF{9,1}(end+1:n) = nan;
PFF {10,1} = [0.69 1.11 1.00 1.87 1.43 1.64 1.81 0.43 0.92 1.84 1.69 1.76 1.92]; PFF{10,1}(end+1:n) = nan;
PFF {11,1} = [-0.13 -0.04 0.06 0.39 0.77 0.28 0.46 0.47 0.78 1.01 1.65 1.41 1.75 2.00 1.90]; PFF{11,1}(end+1:n) = nan;
PFF {12,1} = [0.50 0.10 0.25 0.53 0.10 0.34 0.68 1.13 2.54]; PFF{12,1}(end+1:n) = nan;
PFFall = cell2mat(PFF);
PFF_avg = mean(PFFall,[1],'omitnan');


% figure (2)
redColor = [1 0 0];
for ii = 1:length(PFF)
plot (PFFall(ii,:),'Color', redColor,'LineWidth',1.0)
hold on 
end
plot (PFF_avg,'Color', redColor,'LineWidth',4.0)

yline(1.80,'LineWidth', 2,'Color','k','LineStyle','--')
ylabel('d prime', 'FontSize',20)
xlabel('# training days', 'FontSize',20)
ax = gca;
axis(ax, 'tight')
xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
xlim([0 15])
xticks([0:15])
ylim([-0.5 3.5])
hold off

%% Bar graph between saline and PFF

figure (3)
PFF_days = cellfun(@checkcell,PFF);
saline_days = cellfun(@checkcell,saline);
x1 = ones(1,length(PFF_days)); x2 = 2*ones(1,length(saline_days));
y1 = PFF_days; y1 (isnan(y1)) = 0;
y2 = saline_days; y2 (isnan(y2)) = 0;


a = bar(1,mean(PFF_days,'omitnan'), 0.6, 'FaceColor',[1 0 0],{'DisplayName'}, {'PFF'})
a.FaceAlpha = 0.5;
hold on
b = bar(2,mean(saline_days,'omitnan'), 0.6, 'FaceColor',[0.7 0.7 0.7],{'DisplayName'}, {'Saline'})
b.FaceAlpha = 0.5;
hold on
errorbar(1,mean(PFF_days,'omitnan'),(std(PFF_days,"omitnan")/sqrt(size(PFF_days,1))),...
 'k','LineStyle','none','LineWidth',2,'Color',[0 0 0],'CapSize',12)
hold on
errorbar(2,mean(saline_days,'omitnan'),(std(saline_days,"omitnan")/sqrt(size(saline_days,1))),...
  'k','LineStyle','none','LineWidth',2,'Color',[0 0 0],'CapSize',12)
hold on

scatter_size = 50;
swarmchart((x1+(rand(1,length(x1))-0.5)*0.2),y1,scatter_size, 'k','filled','MarkerFaceAlpha',1,'MarkerFaceColor',...
                   [1 0 0],'MarkerEdgeColor','none','LineWidth',2)
hold on
swarmchart((x2+(rand(1,length(x1))-0.5)*0.2),y2,scatter_size, 'k','filled','MarkerFaceAlpha',1,'MarkerFaceColor',...
                   [0 0 0],'MarkerEdgeColor','none','LineWidth',2)

% xlim([0.4,2.6,4.8]); 
 ylim([0 16])
ylabel( '#Training days','FontSize',15)
legend('PFF','Saline')

%% statistics for training days
allmice = [mean(salineall,[2],'omitnan'); mean(PFFall,[2],'omitnan')];
[h,p] = lillietest(allmice)
p = ranksum(PFF_avg,saline_avg)

% [h,p] = kstest(PFF_avg)
% [h,p] = kstest(saline_avg)
% 
% [h,p] = kstest2(PFF_avg,saline_avg)


%% statistics for threshold coherences
% cd 'C:\Users\atheint\Box\Lab Shared\Data\Theint Theint\Imaging\jRGECO1a\Analysis\Behavior'


A = readtable('Behavior_stats.xlsx')

A.ID = categorical(A.ID);
A.Group = categorical(A.Group);
A.mpi = categorical(A.mpi);
lme_coh = fitlme(A,'coherence90 ~ Group + mpi + Group*mpi + (1 | ID)','FitMethod','REML')
gaov_coh = anova(lme_coh)
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(double(lme_coh.Coefficients(:,6)))


 %% graph for threshold coherences
% load ('C:\Users\atheint\Box\Lab Shared\Data\Theint Theint\Imaging\Analysis\Behavior\behavior_data.mat')
S = struct2table(behavior_data);
mpi = 6;
gptime = cell (2, mpi);   % ROW 2 IS PFF; ROW 1 IS SALINE

for ii = 1: mpi           
    idx = (S.mpi == ii & S.Group == 1);            
    gptime {2,ii} = S(idx,:); 
    idx = (S.mpi == ii & S.Group == 0);
    gptime {1,ii} = S(idx,:);
end

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

% Average for whole grouptime 
                                                   
  for ii = 1:2
      for jj = 1:mpi
           threshold {ii,jj} = mean (gptime {ii,jj}.threshold_adjust,'omitnan');
           threshold90 {ii,jj} = mean (gptime {ii,jj}.threshold_adjust90,'omitnan'); 
           hit_resptime {ii,jj} = mean (gptime {ii,jj}.hit_resptime_avg,'omitnan'); 
           FA_resptime {ii,jj} = mean (gptime {ii,jj}.FA_resptime_avg,'omitnan');  
           perc_correctGo {ii,jj} = mean (gptime {ii,jj}.perc_correctGo_avg,'omitnan'); 
           perc_correctNoGo {ii,jj} = mean (gptime {ii,jj}.perc_correctNoGo_avg,'omitnan');            
           perc_nGo {ii,jj} = mean (gptime {ii,jj}.perc_nGo_avg,'omitnan'); 
           perc_nNoGo {ii,jj} = mean (gptime {ii,jj}.perc_nNoGo_avg,'omitnan'); 
           hit_postlickfreq {ii,jj} = mean (gptime {ii,jj}.hit_postlickfreq_avg,'omitnan');
           hit_postlicktime {ii,jj} = mean (gptime {ii,jj}.hit_postlicktime_avg,'omitnan');
           hit_prelickfreq {ii,jj} = mean (gptime {ii,jj}.hit_prelickfreq_avg,'omitnan');
           hit_firstlick {ii,jj} = mean (gptime {ii,jj}.hit_firstlick_avg,'omitnan');
           FA_postlickfreq {ii,jj} = mean (gptime {ii,jj}.FA_postlickfreq_avg,'omitnan');
           FA_postlicktime {ii,jj} = mean (gptime {ii,jj}.FA_postlicktime_avg,'omitnan');
           FA_prelickfreq {ii,jj} = mean (gptime {ii,jj}.FA_prelickfreq_avg,'omitnan');
           FA_firstlick {ii,jj} = mean (gptime {ii,jj}.FA_firstlick_avg,'omitnan');
           initial_hitrate {ii,jj} = mean (gptime {ii,jj}.initial_hitrate_avg,'omitnan');
           initial_FArate {ii,jj} = mean (gptime {ii,jj}.initial_FArate_avg,'omitnan');
           middle_hitrate {ii,jj} = mean (gptime {ii,jj}.middle_hitrate_avg,'omitnan');
           middle_FArate {ii,jj} = mean (gptime {ii,jj}.middle_FArate_avg,'omitnan');
           final_hitrate {ii,jj} = mean (gptime {ii,jj}.final_hitrate_avg,'omitnan');
           final_FArate {ii,jj} = mean (gptime {ii,jj}.final_FArate_avg,'omitnan');
           initial_resptime {ii,jj} = mean (gptime {ii,jj}.initial_resptime_avg,'omitnan');
           middle_resptime {ii,jj} = mean (gptime {ii,jj}.middle_resptime_avg,'omitnan');
           final_resptime {ii,jj} = mean (gptime {ii,jj}.final_resptime_avg,'omitnan');
           goR8 {ii,jj} = mean (gptime {ii,jj}.goR8_avg,'omitnan');
           nogoR8 {ii,jj} = mean (gptime {ii,jj}.nogoR8_avg,'omitnan');
           goR80 {ii,jj} = mean (gptime {ii,jj}.goR80_avg,'omitnan');
           nogoR80 {ii,jj} = mean (gptime {ii,jj}.nogoR80_avg,'omitnan');
           goCR8 {ii,jj} = mean (gptime {ii,jj}.goCR8_avg,'omitnan');
           nogoCR8 {ii,jj} = mean (gptime {ii,jj}.nogoCR8_avg,'omitnan');
           goCR80 {ii,jj} = mean (gptime {ii,jj}.goCR80_avg,'omitnan');
           nogoCR80 {ii,jj} = mean (gptime {ii,jj}.nogoCR80_avg,'omitnan');
           hitFACR8 {ii,jj} = mean (gptime {ii,jj}.hitFACR8_avg,'omitnan');
           hitFACR80 {ii,jj} = mean (gptime {ii,jj}.hitFACR80_avg,'omitnan');
           hit_resptime8_mpi {ii,jj} = mean (gptime {ii,jj}.hit_resptime8_mpi_avg,'omitnan'); 
           FA_resptime8_mpi {ii,jj} = mean (gptime {ii,jj}.FA_resptime8_mpi_avg,'omitnan');
           hit_resptime80_mpi {ii,jj} = mean (gptime {ii,jj}.hit_resptime80_mpi_avg,'omitnan');
           FA_resptime80_mpi {ii,jj} = mean (gptime {ii,jj}.FA_resptime80_mpi_avg,'omitnan');
      end 
  end  


for ii = 1:2
      for jj = 1:mpi            
             threshold_anim {ii,jj} = gptime {ii,jj}.threshold_adjust;
             threshold90_anim {ii,jj} = gptime {ii,jj}.threshold_adjust90;
             hit_resptime_anim {ii,jj} = gptime {ii,jj}.hit_resptime_avg;
             FA_resptime_anim {ii,jj} = gptime {ii,jj}.FA_resptime_avg;
             perc_correctGo_anim {ii,jj} = gptime {ii,jj}.perc_correctGo_avg;
             perc_correctNoGo_anim {ii,jj} = gptime {ii,jj}.perc_correctNoGo_avg;
             perc_nGo_anim {ii,jj} = gptime {ii,jj}.perc_nGo_avg;
             perc_nNoGo_anim {ii,jj} = gptime {ii,jj}.perc_nNoGo_avg;
             hit_postlickfreq_anim {ii,jj} = gptime {ii,jj}.hit_postlickfreq_avg;
             hit_postlicktime_anim {ii,jj} = gptime {ii,jj}.hit_postlicktime_avg;
             hit_prelickfreq_anim {ii,jj} = gptime {ii,jj}.hit_prelickfreq_avg;
             hit_firstlick_anim {ii,jj} = gptime {ii,jj}.hit_firstlick_avg;
             FA_postlickfreq_anim {ii,jj} = gptime {ii,jj}.FA_postlickfreq_avg;
             FA_postlicktime_anim {ii,jj} = gptime {ii,jj}.FA_postlicktime_avg;
             FA_prelickfreq_anim {ii,jj} = gptime {ii,jj}.FA_prelickfreq_avg;
             FA_firstlick_anim {ii,jj} = gptime {ii,jj}.FA_firstlick_avg;             
             initial_hitrate_anim {ii,jj} = gptime {ii,jj}.initial_hitrate_avg;
             initial_FArate_anim {ii,jj} = gptime {ii,jj}.initial_FArate_avg;
             middle_hitrate_anim {ii,jj} = gptime {ii,jj}.middle_hitrate_avg;
             middle_FArate_anim {ii,jj} = gptime {ii,jj}.middle_FArate_avg;
             final_hitrate_anim {ii,jj} = gptime {ii,jj}.final_hitrate_avg;
             final_FArate_anim {ii,jj} = gptime {ii,jj}.final_FArate_avg;
             initial_resptime_anim {ii,jj} = gptime {ii,jj}.initial_resptime_avg;
             middle_resptime_anim {ii,jj} = gptime {ii,jj}.middle_resptime_avg;
             final_resptime_anim {ii,jj} = gptime {ii,jj}.final_resptime_avg;
             goR8_anim {ii,jj} = gptime {ii,jj}.goR8_avg;
             nogoR8_anim {ii,jj} = gptime {ii,jj}.nogoR8_avg;
             goR80_anim {ii,jj} = gptime {ii,jj}.goR80_avg;
             nogoR80_anim {ii,jj} = gptime {ii,jj}.nogoR80_avg;
             goCR8_anim {ii,jj} = gptime {ii,jj}.goCR8_avg;
             nogoCR8_anim {ii,jj} = gptime {ii,jj}.nogoCR8_avg;
             goCR80_anim {ii,jj} = gptime {ii,jj}.goCR80_avg;
             nogoCR80_anim {ii,jj} = gptime {ii,jj}.nogoCR80_avg;
             hitFACR8_anim {ii,jj} = gptime {ii,jj}.hitFACR8_avg;
             hitFACR80_anim {ii,jj} = gptime {ii,jj}.hitFACR80_avg;
             hit_resptime8_mpi_anim {ii,jj} = gptime {ii,jj}.hit_resptime8_mpi_avg;
             FA_resptime8_mpi_anim {ii,jj} = gptime {ii,jj}.FA_resptime8_mpi_avg;
             hit_resptime80_mpi_anim {ii,jj} = gptime {ii,jj}.hit_resptime80_mpi_avg;
             FA_resptime80_mpi_anim {ii,jj} = gptime {ii,jj}.FA_resptime80_mpi_avg;
           
      end 
 end

     %  SEM

  for ii = 1:2
      for jj = 1:mpi
        threshold_sem {ii,jj} = std(threshold_anim{ii,jj},'omitnan')/sqrt(length(threshold_anim{ii,jj}));
        threshold90_sem {ii,jj} = std(threshold90_anim{ii,jj},'omitnan')/sqrt(length(threshold90_anim{ii,jj}));
        hit_resptime_sem {ii,jj} = std( hit_resptime_anim{ii,jj},'omitnan')./sqrt(length( hit_resptime_anim{ii,jj}));
        FA_resptime_sem {ii,jj} = std( FA_resptime_anim{ii,jj},'omitnan')./sqrt(length( FA_resptime_anim{ii,jj}));
        perc_correctGo_sem {ii,jj} = std( perc_correctGo_anim{ii,jj},'omitnan')./sqrt(length( perc_correctGo_anim{ii,jj}));
        perc_correctNoGo_sem {ii,jj} = std( perc_correctNoGo_anim{ii,jj},'omitnan')./sqrt(length( perc_correctNoGo_anim{ii,jj}));
        perc_nGo_sem {ii,jj} = std( perc_nGo_anim{ii,jj},'omitnan')./sqrt(length( perc_nGo_anim{ii,jj}));
        perc_nNoGo_sem {ii,jj} = std( perc_nNoGo_anim{ii,jj},'omitnan')./sqrt(length( perc_nNoGo_anim{ii,jj}));
        hit_postlickfreq_sem {ii,jj} = std( hit_postlickfreq_anim{ii,jj},'omitnan')./sqrt(length( hit_postlickfreq_anim{ii,jj}));
        hit_postlicktime_sem {ii,jj} = std( hit_postlicktime_anim{ii,jj},'omitnan')./sqrt(length( hit_postlicktime_anim{ii,jj}));
        hit_prelickfreq_sem {ii,jj} = std( hit_prelickfreq_anim{ii,jj},'omitnan')./sqrt(length( hit_prelickfreq_anim{ii,jj}));
        hit_firstlick_sem {ii,jj} = std( hit_firstlick_anim{ii,jj},'omitnan')./sqrt(length( hit_firstlick_anim{ii,jj}));
        FA_postlickfreq_sem {ii,jj} = std(FA_postlickfreq_anim{ii,jj},'omitnan')./sqrt(length( FA_postlickfreq_anim{ii,jj}));
        FA_postlicktime_sem {ii,jj} = std( FA_postlicktime_anim{ii,jj},'omitnan')./sqrt(length( FA_postlicktime_anim{ii,jj}));
        FA_prelickfreq_sem {ii,jj} = std( FA_prelickfreq_anim{ii,jj},'omitnan')./sqrt(length( FA_prelickfreq_anim{ii,jj}));
        FA_firstlick_sem {ii,jj} = std( FA_firstlick_anim{ii,jj},'omitnan')./sqrt(length( FA_firstlick_anim{ii,jj}));     
        initial_hitrate_sem {ii,jj} = std( initial_hitrate_anim{ii,jj},'omitnan')./sqrt(length( initial_hitrate_anim{ii,jj}));
        initial_FArate_sem {ii,jj} = std( initial_FArate_anim{ii,jj},'omitnan')./sqrt(length( initial_FArate_anim{ii,jj}));
        middle_hitrate_sem {ii,jj} = std( middle_hitrate_anim{ii,jj},'omitnan')./sqrt(length(middle_hitrate_anim{ii,jj}));
        middle_FArate_sem {ii,jj} = std( middle_FArate_anim{ii,jj},'omitnan')./sqrt(length( middle_FArate_anim{ii,jj}));
        final_hitrate_sem {ii,jj} = std( final_hitrate_anim{ii,jj},'omitnan')./sqrt(length( final_hitrate_anim{ii,jj}));
        final_FArate_sem {ii,jj} = std( final_FArate_anim{ii,jj},'omitnan')./sqrt(length( final_FArate_anim{ii,jj}));
        initial_resptime_sem {ii,jj} = std( initial_resptime_anim{ii,jj},'omitnan')./sqrt(length( initial_resptime_anim{ii,jj}));
        middle_resptime_sem {ii,jj} = std( middle_resptime_anim{ii,jj},'omitnan')./sqrt(length( middle_resptime_anim{ii,jj}));
        final_resptime_sem {ii,jj} = std( final_resptime_anim{ii,jj},'omitnan')./sqrt(length( final_resptime_anim{ii,jj}));
        goR8_sem {ii,jj} = std( goR8_anim{ii,jj},'omitnan')./sqrt(length( goR8_anim{ii,jj}));
        nogoR8_sem {ii,jj} = std( nogoR8_anim{ii,jj},'omitnan')./sqrt(length( nogoR8_anim{ii,jj}));
        goR80_sem {ii,jj} = std( goR80_anim{ii,jj},'omitnan')./sqrt(length( goR80_anim{ii,jj}));
        nogoR80_sem {ii,jj} = std( nogoR80_anim{ii,jj},'omitnan')./sqrt(length( nogoR80_anim{ii,jj}));
        goCR8_sem {ii,jj} = std( goCR8_anim{ii,jj},'omitnan')./sqrt(length( goCR8_anim{ii,jj}));
        nogoCR8_sem {ii,jj} = std( nogoCR8_anim{ii,jj},'omitnan')./sqrt(length( nogoCR8_anim{ii,jj}));
        goCR80_sem {ii,jj} = std( goCR80_anim{ii,jj},'omitnan')./sqrt(length( goCR80_anim{ii,jj}));
        nogoCR80_sem {ii,jj} = std( nogoCR80_anim{ii,jj},'omitnan')./sqrt(length( nogoCR80_anim{ii,jj}));
        hitFACR8_sem {ii,jj} = std( hitFACR8_anim{ii,jj},'omitnan')./sqrt(length( hitFACR8_anim{ii,jj}));
        hitFACR80_sem {ii,jj} = std( hitFACR80_anim{ii,jj},'omitnan')./sqrt(length( hitFACR80_anim{ii,jj}));
        hit_resptime8_mpi_sem {ii,jj} = std( hit_resptime8_mpi_anim{ii,jj},'omitnan')./sqrt(length( hit_resptime8_mpi_anim{ii,jj}));
        FA_resptime8_mpi_sem {ii,jj} = std( FA_resptime8_mpi_anim{ii,jj},'omitnan')./sqrt(length( FA_resptime8_mpi_anim{ii,jj}));
        hit_resptime80_mpi_sem {ii,jj} = std( hit_resptime80_mpi_anim{ii,jj},'omitnan')./sqrt(length( hit_resptime80_mpi_anim{ii,jj}));
        FA_resptime80_mpi_sem {ii,jj} = std( FA_resptime80_mpi_anim{ii,jj},'omitnan')./sqrt(length( FA_resptime80_mpi_anim{ii,jj}));
        Mouse_num_gonogo (ii,jj) = length(threshold_anim{ii,jj});
      end 
  end 


%  Grouped bar graph with individual points and SEM (Behavior) (capped at 90)

figure(20)
all = cell2mat(threshold90)'; all = all * 100;
all_err  = cell2mat(threshold90_sem)'; all_err = all_err * 100;
% plot bar
b = bar(all, 'grouped');
hold on
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(all);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',all,all_err,'k','LineStyle','none','LineWidth',2,'Color',[0 0 0],'CapSize',12);
hold on
b(1).FaceColor = 'flat';
b(2).FaceColor = 'flat';
b(1).CData(1,:) = [0.7 0.7 0.7]; b(2).CData(1,:) = [1 0 0];
b(1).CData(2,:) = [0.7 0.7 0.7]; b(2).CData(2,:) = [1 0 0];
b(1).CData(3,:) = [0.7 0.7 0.7]; b(2).CData(3,:) = [1 0 0];
b(1).CData(4,:) = [0.7 0.7 0.7]; b(2).CData(4,:) = [1 0 0];
b(1).CData(5,:) = [0.7 0.7 0.7]; b(2).CData(5,:) = [1 0 0];
b(1).CData(6,:) = [0.7 0.7 0.7]; b(2).CData(6,:) = [1 0 0];

alpha(b,.5)

ca = categorical({'1mpi','2mpi','3mpi','4mpi','5mpi','6mpi'});
ca = reordercats(ca,{'1mpi','2mpi','3mpi','4mpi','5mpi','6mpi'});
set(gca,'xticklabel',ca)
% % legend('Saline','PFF','location','Northwest')
ylabel('Threshold coherence (%)')
ylim([0 100])

A = threshold90_anim;
scatter_size = 50; % Adjust size of scatter points
 for i = 1:nbars 
    for j = 1:ngroups
        scatter_y = A{i,j}'*100;
        scatter_x = x(i,j) + (rand(1,length(A{i,j})) - 0.5) * 0.1; % Slight jitter for better visibility
        if i == 1
        swarmchart(scatter_x, scatter_y, scatter_size, 'k', 'filled','MarkerFaceAlpha',1,'MarkerFaceColor',...
                   [0 0 0],'MarkerEdgeColor','none','LineWidth',2); % Black scatter points
        else
        swarmchart(scatter_x, scatter_y, scatter_size, 'filled','MarkerFaceAlpha',1,'MarkerFaceColor',...
                   [1 0 0],'MarkerEdgeColor','none','LineWidth',2); % red scatter points   
        end
    end
 end





 %% calculate how many trials in a  testing session (one session means one day of testing)

 trial =vertcat(behavior_data.trial);
 values = trial(:,2)-trial(:,1)+1;
 sessionname = vertcat(behavior_data.Sessionname);
dates = cellfun(@extractdate, sessionname);

resultDates = [];
resultValues = [];

i = 1;
n = length(dates);
while i <= n
    currDate = dates(i);
    currSum = values(i);
    j = i + 1;

    % Sum while next date is same
    while j <= n && dates(j) == currDate
        currSum = currSum + values(j);
        j = j + 1;
    end
    % Store result
    resultDates(end+1,1) = currDate;
    resultValues(end+1,1) = currSum;
    i = j;  % Skip to next group
end
result = table(resultDates, resultValues);

%% # session to achieve desired number of trials for each coherence

SS = behavior_data; 
numUniqueDates = zeros(numel(SS), 1);  % Preallocate result
for i = 1:numel(SS)
    fileList = SS(i).Sessionname;  % Cell array of filenames
    if isempty(fileList)
        continue  % Skip empty
    end
    % Extract all 8-digit date strings from each filename
    dates = regexp(fileList, '\d{8}', 'match');
    % Get the first 8-digit match from each (adjust if needed)
    dates = cellfun(@(x) x{1}, dates(~cellfun(@isempty, dates)), 'UniformOutput', false);
    % Count unique dates
    numUniqueDates(i) = numel(unique(dates));
end


%% plot performance of individual mice

ID_saline = unique (gptime {1,1}.ID);
ID_PFF = unique (gptime {2,1}.ID);

Saline = nan (length(ID_saline),6);
PFF = nan (length(ID_PFF),6);

for ii = 1: length(ID_saline)
    temp = S.threshold_adjust(S.ID == ID_saline(ii))';
    if length(temp) ~= 6
        temp = [temp nan(1,6-length(temp))];
        Saline (ii,:) = temp;
    else
        Saline (ii,:) = temp;
    end
end
 
for ii = 1: length(ID_PFF)
    temp = S.threshold_adjust(S.ID == ID_PFF(ii))';
    if length(temp) ~= 6
        temp = [temp nan(1,6-length(temp))];
        PFF (ii,:) = temp;
    else
        PFF (ii,:) = temp;
    end
end

Saline = Saline * 100; PFF = PFF * 100;

grayColor = [.7 .7 .7];

figure (4)
mpi = 6; 
for ii = 1: size(PFF,1)
% h = plot(1:mpi,PFF(ii,1:mpi),'-or','LineWidth',1.5);
h = plot(1:mpi,PFF(ii,1:mpi),'o-','Color','r', 'MarkerFaceColor', 'r', 'LineWidth', 1.5,'MarkerSize', 4);
hold on
end

% legend([h j],'PFF', 'Saline','Location','Southeast');
xticks(1:mpi)
str = cell(1,mpi);
for ii = 1:mpi
str {ii} = strcat(num2str(ii),'mpi');
end

xticklabels(str)
ax = gca;
yl = ylim(ax); 
axis(ax, 'tight')
ylim([0 100])
xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
title('Behavior of each mouse','FontSize',15)
ylabel('thres.coh (%)')
hold off 

figure (5)
for ii = 1: size(Saline,1)
% j = plot(1:mpi,Saline(ii,1:mpi),'o-','Color',[0.7 0.7 0.7], 'MarkerFaceColor', [0.7 0.7 0.7], 'LineWidth', 1.5,'MarkerSize', 4); % gray
j = plot(1:mpi,Saline(ii,1:mpi),'o-','Color',[0 0 0], 'MarkerFaceColor', [0 0 0], 'LineWidth', 1.5,'MarkerSize', 4); % gray
hold on
end

% legend([h j],'PFF', 'Saline','Location','Southeast');
xticks(1:mpi)
str = cell(1,mpi);
for ii = 1:mpi
str {ii} = strcat(num2str(ii),'mpi');
end
xticklabels(str)
ax = gca;
yl = ylim(ax); 
axis(ax, 'tight')
ylim([0 100])
xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
title('Behavior of each mouse','FontSize',15)
ylabel('thres.coh (%)')
% xlabel('mpi')

%% Supplementary figures ____ first lick at 4 and 5 MPI

figure (6) % hit trials
valueall = cell2mat(hit_firstlick); 
semall = cell2mat(hit_firstlick_sem); 
G = 1; % set row 1 for saline; set row 2 for PFF
valueallmpi = reshape(valueall(G,:), [6,10]);
value = mean (valueallmpi(4:5,:));   % average the values only for 4 and 5 MPI
semallmpi =  reshape(semall(G,:), [6,10]);
sem = mean (semallmpi([4:5],:));
H = 2;
valueallmpiH = reshape(valueall(H,:), [6,10]);
valueH = mean (valueallmpiH(4:5,:));
semallmpiH =  reshape(semall(H,:), [6,10]);
semH = mean (semallmpiH([4:5],:));


% Set the color you want using rgb
map = [0 0 0         %---> 1st color 
       1 0 0         %---> 2nd color
       0 1 0         %---> 3rd color
       0 0 1         %---> 4th color
       1 0.5 1       %---> 5th color
       0.2 0.5 0.75];  %---> 6th color
       %0.5 0.3 0.8]; %---> 7th color

errorbar(value,sem,'Color',colormap(map(G, :)),'LineWidth',1.5)
hold on
errorbar(valueH,semH,'Color',colormap(map(H, :)),'LineWidth',1.5)

xticks(1:10)
xticklabels({'8','16','24','32','40','48','56','64','72','80'})
ax = gca;
yl = ylim(ax); 
axis(ax, 'tight')
ylim(ax, yl)

xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
xlabel ('Coherence (%)')
ylabel ('Latency to first lick (s)')
ylim([0 1.5])
legend ('Saline', 'PFF','Location','southeast')
hold off

figure (7) % false trials
valueall = cell2mat(FA_firstlick); 
semall = cell2mat(FA_firstlick_sem); 
G = 1; % set row 1 for saline; set row 2 for PFF
valueallmpi = reshape(valueall(G,:), [6,10]);
value = mean (valueallmpi(4:5,:));   % average the values only for 4 and 5 MPI
semallmpi =  reshape(semall(G,:), [6,10]);
sem = mean (semallmpi([4:5],:));
H = 2;
valueallmpiH = reshape(valueall(H,:), [6,10]);
valueH = mean (valueallmpiH(4:5,:));
semallmpiH =  reshape(semall(H,:), [6,10]);
semH = mean (semallmpiH([4:5],:));


% Set the color you want using rgb
map = [0 0 0         %---> 1st color 
       1 0 0         %---> 2nd color
       0 1 0         %---> 3rd color
       0 0 1         %---> 4th color
       1 0.5 1       %---> 5th color
       0.2 0.5 0.75];  %---> 6th color
       %0.5 0.3 0.8]; %---> 7th color

errorbar(value,sem,'Color',colormap(map(G, :)),'LineWidth',1.5)
hold on
errorbar(valueH,semH,'Color',colormap(map(H, :)),'LineWidth',1.5)

xticks(1:10)
xticklabels({'8','16','24','32','40','48','56','64','72','80'})
ax = gca;
yl = ylim(ax); 
axis(ax, 'tight')
ylim(ax, yl)

xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
xlabel ('Coherence (%)')
ylabel ('Latency to first lick (s)')
ylim([0 1.5])
legend ('Saline', 'PFF','Location','southeast')

%%  line graph across timepoints

figure (8) % hit trials
valueall = cell2mat(perc_nGo); 
semall = cell2mat(perc_nGo_sem); 
G = 1; % set row 1 for saline; set row 2 for PFF
valueallmpi = reshape(valueall(G,:), [6,10]);
value = mean (valueallmpi,2);   % average the values across all coherences
value = value';
semallmpi =  reshape(semall(G,:), [6,10]);
sem = mean (semallmpi,2); sem = sem';
H = 2;
valueallmpiH = reshape(valueall(H,:), [6,10]);
valueH = mean (valueallmpiH,2); valueH = valueH';
semallmpiH =  reshape(semall(H,:), [6,10]);
semH = mean (semallmpiH,2); semH = semH';


% Set the color you want using rgb
map = [0 0 0         %---> 1st color 
       1 0 0         %---> 2nd color
       0 1 0         %---> 3rd color
       0 0 1         %---> 4th color
       1 0.5 1       %---> 5th color
       0.2 0.5 0.75];  %---> 6th color
       %0.5 0.3 0.8]; %---> 7th color

errorbar(value,sem,'Color',colormap(map(G, :)),'LineWidth',1.5)
hold on
errorbar(valueH,semH,'Color',colormap(map(H, :)),'LineWidth',1.5)

xticks(1:10)
xticklabels({'1','2','3','4','5','6'})
ax = gca;
yl = ylim(ax); 
axis(ax, 'tight')
ylim(ax, yl)

xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
xlabel ('Coherence (%)')
ylabel ('% success rate in Go trials')
ylim([0 60])
legend ('Saline', 'PFF','Location','southeast')
hold off

figure (9) % false trials
valueall = cell2mat(perc_nNoGo); 
semall = cell2mat(perc_nNoGo_sem); 
G = 1; % set row 1 for saline; set row 2 for PFF
valueallmpi = reshape(valueall(G,:), [6,10]);
value = mean (valueallmpi,2);   % average the values across all coherences
value = value';
semallmpi =  reshape(semall(G,:), [6,10]);
sem = mean (semallmpi,2); sem = sem';
H = 2;
valueallmpiH = reshape(valueall(H,:), [6,10]);
valueH = mean (valueallmpiH,2); valueH = valueH';
semallmpiH =  reshape(semall(H,:), [6,10]);
semH = mean (semallmpiH,2); semH = semH';


% Set the color you want using rgb
map = [0 0 0         %---> 1st color 
       1 0 0         %---> 2nd color
       0 1 0         %---> 3rd color
       0 0 1         %---> 4th color
       1 0.5 1       %---> 5th color
       0.2 0.5 0.75];  %---> 6th color
       %0.5 0.3 0.8]; %---> 7th color

errorbar(value,sem,'Color',colormap(map(G, :)),'LineWidth',1.5)
hold on
errorbar(valueH,semH,'Color',colormap(map(H, :)),'LineWidth',1.5)

xticks(1:10)
xticklabels({'1','2','3','4','5','6'})
ax = gca;
yl = ylim(ax); 
axis(ax, 'tight')
ylim(ax, yl)

xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
xlabel ('Coherence (%)')
ylabel ('% success rate in NoGo trials')
ylim([0 60])
legend ('Saline', 'PFF','Location','southeast')
hold off






 function b = extractdate (filename)
   b = str2num(filename((end-18):(end-11)));
 end

function a = checkcell (cc)

a = length(cc(~isnan(cc)));
end

