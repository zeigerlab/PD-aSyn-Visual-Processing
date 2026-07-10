%% plot bar graph for manually labelled C0505+ cells   ----- spontaneous (supp. fig 9)

load ('isc0505.mat')
load ('notc0505.mat')
C0505pos = {
    [isc0505.zscore_spont]
    [isc0505.AUC_spont]
    [isc0505.peak_amp_spont]
    [isc0505.trans_spont]
};

C0505neg = {
    [notc0505.zscore_spont]
    [notc0505.AUC_spont]
    [notc0505.peak_amp_spont]
    [notc0505.trans_spont]
};

titles = {'zscore','AUC','Peak amplitude','Transient DG'};

for ii = 1:4
    figure(ii); clf; hold on
    y1 = C0505pos{ii}; y2 = C0505neg{ii};
    y1 = y1(~isnan(y1)); y2 = y2(~isnan(y2));
    bar(1,mean(y1),0.6,'FaceColor',[1 0 0],'FaceAlpha',0.5);
    bar(2,mean(y2),0.6,'FaceColor',[0 0 0],'FaceAlpha',0.5);
    errorbar(1,mean(y1),std(y1)/sqrt(numel(y1)),...
        'k','LineStyle','none','LineWidth',2,'CapSize',12);
    errorbar(2,mean(y2),std(y2)/sqrt(numel(y2)),...
        'k','LineStyle','none','LineWidth',2,'CapSize',12);
    swarmchart(ones(size(y1)),y1,20,[1 0 0]);
    swarmchart(2*ones(size(y2)),y2,20,[0 0 0]);
    xlim([0.5 2.5])
    xticks([1 2])
    xticklabels({'C0505+','C0505-'})
    title(titles{ii})
    hold off
end


%% correlation between zscore and c05-05 density  ---- figure 4m
close all
clear all

load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\corr_isc0505_spontall.mat')

c0505wtcell_den = extractfield(corr_isc0505_spontall, 'c05incell_den');
c0505wtcell_total = extractfield(corr_isc0505_spontall, 'c05incell_total');
eachcellactavg = extractfield(corr_isc0505_spontall, 'eachcellactavg');

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
text(max(x) - 0.15, max(y) - 0.2, sprintf('r = %.3f', pearsonR), ...
    'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold');
prob = prob (1,2);
text(max(x) - 0.15, max(y) - 0.6, sprintf('p = %.3e', prob), ...
    'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold');
 xlabel('Density of C0505');
 ylabel('Mean cell activity of each cell (z-score)');

























%% plot bar graph for manually labelled C0505+ cells   ----- spontaenous

% C0505pos = [isc0505(:).zscore_spont];
% C0505neg = [notc0505(:).zscore_spont];

% C0505pos = [isc0505(:).peak_amp_spont];
% C0505neg = [notc0505(:).peak_amp_spont];
% 
% C0505pos = [isc0505(:).AUC_spont];
% C0505neg = [notc0505(:).AUC_spont];
% 
% C0505pos = [isc0505(:).trans_spont];
% C0505neg = [notc0505(:).trans_spont];

% x1 = ones(1,length(C0505pos)); x2 = 2*ones(1,length(C0505neg));
% 
% y1 = C0505pos; y1 (isnan(y1)) = 0;
% y2 = C0505neg; y2 (isnan(y2)) = 0;
% swarmchart(x1,y1,[],[1 0 0]); hold on
% swarmchart(x2,y2,[],[0 0 0]); hold on
% 
% a = bar(1,mean(C0505pos,'omitnan'), 0.6, 'FaceColor',[1 0 0],{'DisplayName'}, {'C0505pos'})
% a.FaceAlpha = 0.5; hold on
% b = bar(2,mean(C0505neg,'omitnan'), 0.6, 'FaceColor',[0 0 0],{'DisplayName'}, {'C0505neg'})
% b.FaceAlpha = 0.5; hold on
% 
% errorbar(1,mean(C0505pos,'omitnan'),(std(C0505pos,"omitnan")/sqrt(length(C0505pos))),...
%  'k','LineStyle','none','LineWidth',2,'Color',[0 0 0],'CapSize',12)
% hold on
% errorbar(2,mean(C0505neg,'omitnan'),(std(C0505neg,"omitnan")/sqrt(length(C0505neg))),...
%   'k','LineStyle','none','LineWidth',2,'Color',[0 0 0],'CapSize',12)
% hold off
% ylim([0 7])
% ylabel( 'Peak Amplitude (z-score)','FontSize',15)