%% plot bar graph for manually labelled C0505+ cells   ----- DG  (figure 4 c-f)
clear all
close all
load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\isc0505.mat')
load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\notc0505.mat')

C0505pos(1,:) = [isc0505(:).zscore_DG]; C0505neg(1,:) = [notc0505(:).zscore_DG];
C0505pos(2,:) = [isc0505(:).AUC_DG]; C0505neg(2,:) = [notc0505(:).AUC_DG];
C0505pos(3,:) = [isc0505(:).peak_amp]; C0505neg(3,:) = [notc0505(:).peak_amp]; 
C0505pos(4,:) = [isc0505(:).trans_DG]; C0505neg(4,:) = [notc0505(:).trans_DG];
titles = {'zscore','AUC','Peak amplitude','Transient DG'};

for ii = 1:4
    figure(ii); clf
    hold on
    x1 = ones(1,size(C0505pos,2)); x2 = 2*ones(1,size(C0505neg,2));
    y1 = C0505pos(ii,:); y2 = C0505neg(ii,:);
    y1 = y1(~isnan(y1)); y2 = y2(~isnan(y2));  
    a = bar(1,mean(y1),0.6,'FaceColor',[1 0 0]); a.FaceAlpha = 0.5;
    b = bar(2,mean(y2),0.6,'FaceColor',[0 0 0]); b.FaceAlpha = 0.5;  
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

%% plotting pie chart for visually responsive C0505+ and C0505- cells
clear all
pos = [32, 68];  neg = [45, 108]; % responsive, non-responsive 
responsiveColor = [27, 158, 119] / 255; % green
nonResponsiveColor = [217, 217, 217] / 255; % light gray
figure;
subplot(2,2,1);
pie(pos);
colormap([responsiveColor; nonResponsiveColor]);
title('C05-05+ (n=100)');

subplot(2,2,2);
pie(neg);
colormap([responsiveColor; nonResponsiveColor]);
title('C05-05- (n=153)');

subplot(2,2,3); rectangle('Position',[0 0 1 1], 'FaceColor', responsiveColor, 'EdgeColor', 'none');
subplot(2,2,4); rectangle('Position',[0 0 1 1], 'FaceColor', nonResponsiveColor, 'EdgeColor', 'none');


%%  OSI/DSI for C0505pos and C0505neg cells ---- Figure 4h,i

close all
clear all
 load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\c0505_respinfo_pos.mat')
 load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\c0505_respinfo_neg.mat')
% clearvars -except C0505pos  C0505neg

titles = {'OSI','DSI'};
for ii = 3:4 % row 3 for OSI and row 4 for DSI
     C0505pos = c0505_respinfo_pos (ii,:);C0505neg = c0505_respinfo_neg (ii,:);     
    
    C0505pos = C0505pos (c0505_respinfo_pos (1,:)==1);
    C0505neg = C0505neg (c0505_respinfo_neg (1,:)==1);    
    
    x1 = ones(1,length(C0505pos)); x2 = 2*ones(1,length(C0505neg));
    y1 = C0505pos; y1 (isnan(y1)) = 0; y2 = C0505neg; y2 (isnan(y2)) = 0;
    figure (ii)
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
     title(titles{ii-2})
    hold off   
end


%%  graphs for MI for C0505pos and C0505neg cells - Figure 4j
close all
clear all

figure (1);  
load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\isc0505_MI.mat')
load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\notc0505_MI.mat')
load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\is_postz.mat')
load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\not_postz.mat')

C0505pos = is_postz (8,:); C0505neg = not_postz (8,:);
C0505pos = C0505pos (is_postz (9,:)==1); C0505neg = C0505neg (not_postz (9,:)==1);

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
hold off
title('Modulation Index')

%% correlation between zscore and c05-05 density  ---- figure 4l
close all
clear all
load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\corr_isc0505_DGall.mat')

c0505wtcell_den = extractfield(corr_isc0505_DGall, 'c05incell_den');
c0505wtcell_total = extractfield(corr_isc0505_DGall, 'c05incell_total');
eachcellactavg = extractfield(corr_isc0505_DGall, 'eachcellactavg');


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