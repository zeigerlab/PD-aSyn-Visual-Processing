     %rho  = [AUC_zeroA_avg AUC_zeroB_avg AUC_zeroC_avg AUC_zeroD_avg AUC_zeroE_avg AUC_zeroF_avg AUC_zeroG_avg AUC_zeroH_avg AUC_zeroA_avg];
    % 0 45 90 135 180 225 270 315 0
     rho  = [0.20 1 0.1 0.07 0.1 0.45 0.05 0.1 0.20];
    rho = rho./max(rho,[],2);


    theta = 0 : pi/4: 2*pi;
    p= figure;
    polarplot (theta, rho );
    pax = gca;
    thetaticks(0:45:315)
    pax.ThetaDir = 'clockwise';
    pax.ThetaZeroLocation = 'right';
    pax.RTickLabel = [];                             %remove rho values inside polar plot
    hlines = findall(gcf,'Type','line'); set(hlines,'LineWidth',3); %inside lines thicker
    rl = rlim; hold on
    polarplot([0 pi], rl(2)*[1 1], 'k--');           %connecting 0 and 180
    polarplot([3*pi/2 pi/2], rl(2)*[1 1], 'k--');    %connecting 90 and 270
    polarplot(linspace(0, 2*pi, 61), rl(2)*ones(61,1), 'k-', 'LineWidth', 2)    %making border thicker
    grid off; 
    OSI = 0.82; DSI = 0.41;
    title (sprintf('ROI %d: OSI %0.2f DSI %0.2f', i, OSI, DSI ))
%     cd(path_stim_all{itr})
%      savefig (gcf,strcat('ROI', '_', num2str(i), '_', 'OSI', '_', num2str (OSI(i)), 'DSI', '_', num2str (DSI(i)),'.fig'));