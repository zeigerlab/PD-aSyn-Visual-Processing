% z-score and AUC

load ('c0505_iv_dmso.mat')

% z-score
all_preF = cat(2, c0505_iv_dmso.pre_F);
all_postF = cat(2, c0505_iv_dmso.post_F);

%statistics
[a,b] = ttest(mean(all_preF,1),mean(all_postF,1))   % z-score t-test


figure (1)
row1 = mean(all_preF,1); row2 = mean(all_postF,1); n = length(row1);
m1 = mean(row1); m2 = mean(row2);
sem1 = std(row1) / sqrt(n); sem2 = std(row2) / sqrt(n);


hold on

% bars
bar(1, m1, 'FaceColor', [0.85 0.85 0.85])   % light grey
bar(2, m2, 'FaceColor', [1.0 0.7 0.7])       % light red

% SEM error bars
errorbar(1, m1, sem1, 'k', 'LineWidth', 1, 'CapSize', 10)
errorbar(2, m2, sem2, 'k', 'LineWidth', 1, 'CapSize', 10)

% shifted x positions
x1 = 1.08;   % Pre points shifted right
x2 = 1.92;   % Post points shifted left

% paired lines + dots (grey)
for i = 1:n
    plot([x1 x2], [row1(i) row2(i)], '-o', ...
        'Color', [0.6 0.6 0.6], ...
        'MarkerFaceColor', [0.6 0.6 0.6], ...
        'MarkerEdgeColor', [0.6 0.6 0.6])
end

xlim([0.5 2.5])
xticks([1 2])
xticklabels({'Pre','Post'})

% plot AUC


pre_AUC = trapz( all_preF, 1); pre_AUC(pre_AUC <0) = 0;
post_AUC = trapz( all_postF, 1);post_AUC(post_AUC <0) = 0;
[c,d] = ttest(pre_AUC,post_AUC)

figure (2)
row3 = pre_AUC; row4 = post_AUC; n = length(row3);
m1 = mean(row3); m2 = mean(row4);
sem1 = std(row3) / sqrt(n); sem2 = std(row4) / sqrt(n);
hold on

% bars
bar(1, m1, 'FaceColor', [0.85 0.85 0.85])   % light grey
bar(2, m2, 'FaceColor', [1.0 0.7 0.7])       % light red

% SEM error bars
errorbar(1, m1, sem1, 'k', 'LineWidth', 1, 'CapSize', 10)
errorbar(2, m2, sem2, 'k', 'LineWidth', 1, 'CapSize', 10)

% shifted x positions
x1 = 1.08;   % Pre points shifted right
x2 = 1.92;   % Post points shifted left

% paired lines + dots (grey)
for i = 1:n
    plot([x1 x2], [row3(i) row4(i)], '-o', ...
        'Color', [0.6 0.6 0.6], ...
        'MarkerFaceColor', [0.6 0.6 0.6], ...
        'MarkerEdgeColor', [0.6 0.6 0.6])
end

xlim([0.5 2.5])
xticks([1 2])
xticklabels({'Pre','Post'})
% transient rate

    pre_rate = []; pre_peak = []; framerate = 10;   
    duration = 1.5; %in min

for ii = 1:size (all_preF,2)
    [amp_pre, idx_pre] = findpeaks (all_preF (:,ii),  'MinPeakHeight',4); 
    [amp_post, idx_post] = findpeaks (all_postF (:,ii),  'MinPeakHeight',4);   
    pre_peakamp (1,ii) =  mean(amp_pre); %calcium transients
    pre_rate(1,ii) = length(idx_pre)/duration;   %frequency of calcium transients (per min)
    post_peakamp (1,ii) =  mean(amp_post);
    post_rate(1,ii) = length(idx_post)/duration;   
   
end
pre_peakamp(isnan(pre_peakamp)) = 0;post_peakamp(isnan(post_peakamp)) = 0;

[e,f] = ttest(pre_peakamp,post_peakamp)
[g,h] = ttest(pre_rate,post_rate)

figure (3)
row5 = pre_peakamp; row6 = post_peakamp; n = length(row5);
m1 = mean(row5); m2 = mean(row6);
sem1 = std(row5) / sqrt(n); sem2 = std(row6) / sqrt(n);
hold on

% bars
bar(1, m1, 'FaceColor', [0.85 0.85 0.85])   % light grey
bar(2, m2, 'FaceColor', [1.0 0.7 0.7])       % light red

% SEM error bars
errorbar(1, m1, sem1, 'k', 'LineWidth', 1, 'CapSize', 10)
errorbar(2, m2, sem2, 'k', 'LineWidth', 1, 'CapSize', 10)

% shifted x positions
x1 = 1.08;   % Pre points shifted right
x2 = 1.92;   % Post points shifted left

% paired lines + dots (grey)
for i = 1:n
    plot([x1 x2], [row5(i) row6(i)], '-o', ...
        'Color', [0.6 0.6 0.6], ...
        'MarkerFaceColor', [0.6 0.6 0.6], ...
        'MarkerEdgeColor', [0.6 0.6 0.6])
end

xlim([0.5 2.5])
xticks([1 2])
xticklabels({'Pre','Post'})

figure (4)
row7 = pre_rate; row8 = post_rate; n = length(row5);
m1 = mean(row7, 'omitnan'); m2 = mean(row8, 'omitnan');
sem1 = std(row7) / sqrt(n); sem2 = std(row8) / sqrt(n);
hold on

% bars
bar(1, m1, 'FaceColor', [0.85 0.85 0.85])   % light grey
bar(2, m2, 'FaceColor', [1.0 0.7 0.7])       % light red

% SEM error bars
errorbar(1, m1, sem1, 'k', 'LineWidth', 1, 'CapSize', 10)
errorbar(2, m2, sem2, 'k', 'LineWidth', 1, 'CapSize', 10)

% shifted x positions
x1 = 1.08;   % Pre points shifted right
x2 = 1.92;   % Post points shifted left

% paired lines + dots (grey)
for i = 1:n
    plot([x1 x2], [row7(i) row8(i)], '-o', ...
        'Color', [0.6 0.6 0.6], ...
        'MarkerFaceColor', [0.6 0.6 0.6], ...
        'MarkerEdgeColor', [0.6 0.6 0.6])
end

xlim([0.5 2.5])
xticks([1 2])
xticklabels({'Pre','Post'})


