%%  z-score of C05-05-negative neurons vs FOV  --- Figure 5c

load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\corr_isc0505_spontall.mat')
x = [corr_isc0505_spontall.c05signal_avg]; 
 

for ii = 1: length (corr_isc0505_spontall)
    aa = corr_isc0505_spontall(ii).eachcellactavg;
    corr_isc0505_spontall(ii).cellwoc0505_zscore = aa (corr_isc0505_spontall(ii).c05incell_total == 0);
    corr_isc0505_spontall(ii).cellwoc0505_zscoreavg = mean (corr_isc0505_spontall(ii).cellwoc0505_zscore);
end

y = [corr_isc0505_spontall.cellwoc0505_zscoreavg];
[R prob] = corrcoef(x, y);
pearsonR = R(1, 2); 
figure (3);
scatter(x, y, 'filled','k'); 
hold on;
p = polyfit(x, y, 1); 
yFit = polyval(p, x); 
plot(x, yFit, 'r--', 'LineWidth', 2); 
text(max(x) - 0.1, max(y) - 1, sprintf('r = %.3f', pearsonR), ...
    'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold');
prob = prob (1,2);
text(max(x) - 0.1, max(y) - 1.1, sprintf('p = %.3f', prob), ...
    'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold');
 xlabel('C0505 signal (AU)');
 ylabel('Mean cell activity (z-score)');
 ylim([0 1.5])
 xticks([0:4000:12000])

  %% jRGECO1a+ - C05-05- neurons vs 200 pixels ----- figure 5f
% load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\corr_isc0505_spontall.mat')
c0505ardcell_200_refined = extractfield(corr_isc0505_spontall, 'c05ardcell_200_refined');
eachcellactavg_refined = extractfield(corr_isc0505_spontall, 'eachcellactavg_refined');
x = c0505ardcell_200_refined; x(isnan(x)) = []; 
y = eachcellactavg_refined; y(isnan(y)) = [];
[R prob] = corrcoef(x, y);
pearsonR = R(1, 2); 
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

  %% jRGECO1a+ - C05-05- neurons vs 100 pixels ----- supp. figure 11b
% load ('C:\Users\atheint\Box\PD aSyn Visual Processing 2025\Code\Figure4\corr_isc0505_spontall.mat')
c0505ardcell_100_refined = extractfield(corr_isc0505_spontall, 'c05ardcell_100_refined');
eachcellactavg_refined = extractfield(corr_isc0505_spontall, 'eachcellactavg_refined');
x = c0505ardcell_100_refined; x(isnan(x)) = []; 
y = eachcellactavg_refined; y(isnan(y)) = [];
[R prob] = corrcoef(x, y);
pearsonR = R(1, 2); 
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
ylim([-4 8])

