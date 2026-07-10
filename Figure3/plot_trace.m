subplot(3,1,1)

 FOV = 60; ROI = 1;   % for saline
% FOV = 139; ROI = 10;

y = EvokedData_Spont(FOV).signal_traces(1:1000,ROI)'; % x-value of signal
x = 1: length(y); % y-values of signal

text(100, max(EvokedData_Spont(FOV).signal_traces(:,ROI)) - 0.5, sprintf('FOV = %d and ROI = %d', FOV, ROI), ...
    'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold');
[pk, loc] = findpeaks(y, 'MinPeakDistance',4, 'MinPeakHeight',4);
plot(x,y,'-k'); hold on

for ii = 1: length(pk)    
    plot(loc (ii),pk(ii) + 1.5,'k*')
end
ylim ([-10 20])
yticks([-10:5:20])

subplot(3,1,2)
 FOV = 96; ROI = 50; % for saline
% FOV = 124; ROI = 7;

x = 1: length(x); % y-values of signal
y = EvokedData_Spont(FOV).signal_traces(1:1000,ROI)'; % x-value of signal
text(100, max(EvokedData_Spont(FOV).signal_traces(:,ROI)) - 0.5, sprintf('FOV = %d and ROI = %d', FOV, ROI), ...
    'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold');
[pk, loc] = findpeaks(y, 'MinPeakDistance',4, 'MinPeakHeight',4);
plot(x,y,'-k'); hold on

for ii = 1: length(pk)    
    plot(loc (ii),pk(ii) + 1.5,'k*')
end
ylim ([-10 20])
yticks([-10:5:20])

subplot(3,1,3)
 FOV = 76; ROI = 85; % for saline
% FOV = 143; ROI = 3;

x = 1: length(x); % y-values of signal
y = EvokedData_Spont(FOV).signal_traces(1:1000,ROI)'; % x-value of signal
text(100, max(EvokedData_Spont(FOV).signal_traces(:,ROI)) - 0.5, sprintf('FOV = %d and ROI = %d', FOV, ROI), ...
    'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold');
[pk, loc] = findpeaks(y, 'MinPeakDistance',4, 'MinPeakHeight',4);
plot(x,y,'-k'); hold on

for ii = 1: length(pk)    
    plot(loc (ii),pk(ii) + 1.5,'k*')
end

ylim ([-10 20])
yticks([-10:5:20])
hold off