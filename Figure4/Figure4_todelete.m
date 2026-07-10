%%  manual labeling C0505  ---- DG
% the cell labeling code for both DG and spontaneous is c0505_singlecells

load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\isc0505.mat')
load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\notc0505.mat')

a = cell2mat({isc0505(:).peak_amp});  b = mean(a,'omitnan');
a1 = cell2mat({notc0505(:).peak_amp}); b1 = mean(a1,'omitnan');
[h,p] = ttest2(a,a1)

c = cell2mat({isc0505(:).trans_DG}); d = mean(c,'omitnan');
c1 = cell2mat({notc0505(:).trans_DG}); d1 = mean(c1,'omitnan');
[h,p] = ttest2(c,c1)

e = cell2mat({isc0505(:).AUC_DG}); f = mean(e,'omitnan');
e1 = cell2mat({notc0505(:).AUC_DG}); f1 = mean(e1,'omitnan');
[h,p] = ttest2(e,e1) 

g = cell2mat({isc0505(:).zscore_DG}); h = mean(g,'omitnan');
g1 = cell2mat({notc0505(:).zscore_DG}); h1 = mean(g1,'omitnan');
[h,p] = ttest2(g,g1) 

     %% spontaneous ----- statistics
a = cell2mat({isc0505(:).peak_amp_spont});  b = mean(a,'omitnan');
a1 = cell2mat({notc0505(:).peak_amp_spont}); b1 = mean(a1,'omitnan');
[h,p] = ttest2(a,a1)
% b = 5.4140; b1 = 5.8286; h=1; p = 0.0150

c = cell2mat({isc0505(:).trans_spont}); d = mean(c,'omitnan');
c1 = cell2mat({notc0505(:).trans_spont}); d1 = mean(c1,'omitnan');
[h,p] = ttest2(c,c1)
% d = 23.43931; d1 = 26.359296; h=1; p = 0.0406170;

e = cell2mat({isc0505(:).AUC_spont}); f = mean(e,'omitnan');
e1 = cell2mat({notc0505(:).AUC_spont}); f1 = mean(e1,'omitnan');
[h,p] = ttest2(e,e1) 
% f = 273.1822; f1 = 356.7997; p = 0.0056;

g = cell2mat({isc0505(:).zscore_spont}); h = mean(g,'omitnan');
g1 = cell2mat({notc0505(:).zscore_spont}); h1 = mean(g1,'omitnan');
[j,p] = ttest2(g,g1) 
% h = 0.8860; h1= 1.1917; p = 0.0036;


%% neurons with C05-05 inclusion --- DG ---- threshold

% load ('C:\Users\atheint\Box\Lab Shared\Data\Theint Theint\Imaging\Analysis\C0505\corr_isc0505_DGall.mat')
close all
c0505wtcell_den = extractfield(corr_isc0505_DGall, 'c05incell_den');
c0505wtcell_total = extractfield(corr_isc0505_DGall, 'c05incell_total');
eachcellactavg = extractfield(corr_isc0505_DGall, 'eachcellactavg');
% eachcellactavg = extractfield(corr_isc0505_DGall, 'AUC');


idx = find (c0505wtcell_total <= 10);
c0505wtcell_den(idx) = [];
eachcellactavg(idx) = [];
x = c0505wtcell_den; y = eachcellactavg;

[R prob] = corrcoef(x, y);
pearsonR = R(1, 2); % Extract the correlation coefficient
figure (1);
scatter(x, y, 'filled','k'); hold on;
p = polyfit(x, y, 1); 
yFit = polyval(p, x); 
plot(x, yFit, 'r-', 'LineWidth', 2); 
text(max(x) - 0.01, max(y) - 0.2, sprintf('r = %.3f', pearsonR), ...
    'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold');
prob = prob (1,2);
text(max(x) - 0.01, max(y) - 0.6, sprintf('p = %.3e', prob), ...
    'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold');
 xlabel('Density of C0505');
 ylabel('Mean cell activity of each cell (z-score)');


 %% neurons with C05-05 inclusion --- Spont ---- threshold

% load ('C:\Users\atheint\Box\Lab Shared\Data\Theint Theint\Imaging\Analysis\C0505\corr_isc0505_spontall.mat')

c0505wtcell_den = extractfield(corr_isc0505_spontall, 'c05incell_den');
c0505wtcell_total = extractfield(corr_isc0505_spontall, 'c05incell_total');
% eachcellactavg = extractfield(corr_isc0505_spontall, 'eachcellactavg');
eachcellactavg = extractfield(corr_isc0505_spontall, 'trans');

idx = find (c0505wtcell_total <= 10);
c0505wtcell_den(idx) = [];
eachcellactavg(idx) = [];
x = c0505wtcell_den; y = eachcellactavg;

[R prob] = corrcoef(x, y);
pearsonR = R(1, 2); % Extract the correlation coefficient
figure (1);
scatter(x, y, 'filled','k'); hold on;
p = polyfit(x, y, 1); 
yFit = polyval(p, x); 
plot(x, yFit, 'r-', 'LineWidth', 2); 
text(max(x) - 0.01, max(y) - 0.2, sprintf('r = %.3f', pearsonR), ...
    'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold');
prob = prob (1,2);
text(max(x) - 0.01, max(y) - 0.6, sprintf('p = %.3e', prob), ...
    'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold');
 xlabel('Density of C0505');
 ylabel('Mean cell activity of each cell (z-score)');

%% binarized figures for C0505

load ('corr_isc0505_DG.mat')
cd 'C:\Users\atheint\Desktop\S2Pc0505\973-4mpi-DG-02'
I = imread('C0505.tif');
figure (1)
BW1 = imbinarize(I,"adaptive","Sensitivity",0.45);
Kmedian1 = medfilt2(BW1,[5 5]);
c05signal = sum(Kmedian1,'all');
imshow(Kmedian1)
Kmedian1 = double(Kmedian1);


load ('C:\Users\atheint\Desktop\S2Pc0505\973-4mpi-DG-02\Fall.mat')
framerate = 10.014333333333333;
traces_all=S2P_Z_Fcalc_all(F,Fneu,iscell,stat,framerate);
traces=S2P_Z_Fcalc(F,Fneu,iscell,stat,framerate);
meancellact = mean (traces,2);



%%  OSI/DSI for C0505pos and C0505neg cells
close all
figure (22);  % use c0505_respinfo_neg.mat and c0505_respinfo_pos.mat
% load ('C:\Users\atheint\Box\Lab Shared\Data\Theint Theint\Imaging\Analysis\C0505\c0505_respinfo_pos.mat')
% load ('C:\Users\atheint\Box\Lab Shared\Data\Theint Theint\Imaging\Analysis\C0505\c0505_respinfo_neg.mat')
% clearvars -except C0505pos  C0505neg

 C0505pos = c0505_respinfo_pos (3,:);C0505neg = c0505_respinfo_neg (3,:);  % OSI
%   C0505pos = c0505_respinfo_pos (4,:);C0505neg = c0505_respinfo_neg (4,:);  % DSI

C0505pos = C0505pos (c0505_respinfo_pos (1,:)==1);
C0505neg = C0505neg (c0505_respinfo_neg (1,:)==1);


x1 = ones(1,length(C0505pos)); x2 = 2*ones(1,length(C0505neg));
y1 = C0505pos; y1 (isnan(y1)) = 0; y2 = C0505neg; y2 (isnan(y2)) = 0;
swarmchart(x1,y1,[],[1 0 0]); hold on
swarmchart(x2,y2,[],[0 0 0]); hold on
a = bar(1,mean(C0505pos,'omitnan'), 0.6, 'FaceColor',[1 0 0],{'DisplayName'}, {'C0505pos'})
a.FaceAlpha = 0.5; hold on
b = bar(2,mean(C0505neg,'omitnan'), 0.6, 'FaceColor',[0 0 0],{'DisplayName'}, {'C0505neg'})
b.FaceAlpha = 0.5; hold on

errorbar(1,mean(C0505pos,'omitnan'),(std(C0505pos,"omitnan")/sqrt(size(C0505pos,2))),...
 'k','LineStyle','none','LineWidth',2,'Color',[0 0 0],'CapSize',12)
hold on
errorbar(2,mean(C0505neg,'omitnan'),(std(C0505neg,"omitnan")/sqrt(size(C0505neg,2))),...
  'k','LineStyle','none','LineWidth',2,'Color',[0 0 0],'CapSize',12)
hold on
% ylabel( 'DSI','FontSize',15)


a = C0505pos;  b = mean(a,'omitnan');
a1 = C0505neg; b1 = mean(a1,'omitnan');
[h,p] = ttest2(a,a1)


%% plotting pie chart for proportion of visually responsive C0505+ and C0505- cells that pass threshold of amp 4/frame 4 apart
pos = [11, 21];  neg = [31, 14]; % responsive, non-responsive 
responsiveColor = [27, 158, 119] / 255; % green
nonResponsiveColor = [217, 217, 217] / 255; % light gray
figure;
subplot(2,2,1);
pie(pos);
colormap([responsiveColor; nonResponsiveColor]);
title('C05-05+ (n=32)');

subplot(2,2,2);
pie(neg);
colormap([responsiveColor; nonResponsiveColor]);
title('C05-05- (n=45)');

subplot(2,2,3);
rectangle('Position',[0 0 1 1], 'FaceColor', responsiveColor, 'EdgeColor', 'none');
subplot(2,2,4);
rectangle('Position',[0 0 1 1], 'FaceColor', nonResponsiveColor, 'EdgeColor', 'none');


%%  graphs for preferred direction/orientation for C0505pos and C0505neg cells
close all
figure (22);  % use c0505_respinfo_neg.mat and c0505_respinfo_pos.mat
% load ('C:\Users\atheint\Box\Lab Shared\Data\Theint Theint\Imaging\Analysis\C0505\c0505_respinfo_pos.mat')
% load ('C:\Users\atheint\Box\Lab Shared\Data\Theint Theint\Imaging\Analysis\C0505\c0505_respinfo_neg.mat')
% clearvars -except C0505pos  C0505neg

C0505pos = c0505_respinfo_pos (60,:);C0505neg = c0505_respinfo_neg (60,:);   % transient rate
C0505pos(isnan(C0505pos)) = 0; C0505neg(isnan(C0505neg)) = 0;
C0505pos = C0505pos (c0505_respinfo_pos (1,:)==1);
C0505neg = C0505neg (c0505_respinfo_neg (1,:)==1);



x1 = ones(1,length(C0505pos)); x2 = 2*ones(1,length(C0505neg));
y1 = C0505pos;  y2 = C0505neg; 
y1 (isnan(y1)) = 0; y2 (isnan(y2)) = 0;
swarmchart(x1,y1,[],[1 0 0]); hold on
swarmchart(x2,y2,[],[0 0 0]); hold on
a = bar(1,mean(C0505pos,'omitnan'), 0.6, 'FaceColor',[1 0 0],{'DisplayName'}, {'C0505pos'})
a.FaceAlpha = 0.5; hold on
b = bar(2,mean(C0505neg,'omitnan'), 0.6, 'FaceColor',[0 0 0],{'DisplayName'}, {'C0505neg'})
b.FaceAlpha = 0.5; hold on

errorbar(1,mean(C0505pos,'omitnan'),(std(C0505pos,"omitnan")/sqrt(length(C0505pos))),...
 'k','LineStyle','none','LineWidth',2,'Color',[0 0 0],'CapSize',12)
hold on
errorbar(2,mean(C0505neg,'omitnan'),(std(C0505neg,"omitnan")/sqrt(length(C0505neg))),...
  'k','LineStyle','none','LineWidth',2,'Color',[0 0 0],'CapSize',12)
hold on
% ylabel( 'DSI','FontSize',15)



%%  graphs for MI for C0505pos and C0505neg cells
close all
figure (22);  
% load ('C:\Users\atheint\Box\Lab Shared\Data\Theint Theint\Imaging\Analysis\C0505\isc0505_MI.mat')
% load ('C:\Users\atheint\Box\Lab Shared\Data\Theint Theint\Imaging\Analysis\C0505\notc0505_MI.mat')


 C0505pos = is_postz (8,:);
 C0505neg = not_postz (8,:);
C0505pos = C0505pos (is_postz (9,:)==1);
C0505neg = C0505neg (not_postz (9,:)==1);

% C0505pos = is (3,:) ;
%  C0505neg = not (3,:);

x1 = ones(1,length(C0505pos)); x2 = 2*ones(1,length(C0505neg));
y1 = C0505pos;  y2 = C0505neg; 
y1 (isnan(y1)) = 0; y2 (isnan(y2)) = 0;
swarmchart(x1,y1,[],[1 0 0]); hold on
swarmchart(x2,y2,[],[0 0 0]); hold on
a = bar(1,mean(C0505pos,'omitnan'), 0.6, 'FaceColor',[1 0 0],{'DisplayName'}, {'C0505pos'})
a.FaceAlpha = 0.5; hold on
b = bar(2,mean(C0505neg,'omitnan'), 0.6, 'FaceColor',[0 0 0],{'DisplayName'}, {'C0505neg'})
b.FaceAlpha = 0.5; hold on

errorbar(1,mean(C0505pos,'omitnan'),(std(C0505pos,"omitnan")/sqrt(length(C0505pos))),...
 'k','LineStyle','none','LineWidth',2,'Color',[0 0 0],'CapSize',12)
hold on
errorbar(2,mean(C0505neg,'omitnan'),(std(C0505neg,"omitnan")/sqrt(length(C0505neg))),...
  'k','LineStyle','none','LineWidth',2,'Color',[0 0 0],'CapSize',12)
hold on
% ylabel( 'DSI','FontSize',15)

%%
a = C0505pos;  b = mean(a,'omitnan');
a1 = C0505neg; b1 = mean(a1,'omitnan');
[h,p] = ttest2(a,a1)












