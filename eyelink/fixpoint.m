%% fixpoint
!grep TRIALID events/07oct09.DW1.asc  | awk '{ print $2 }' > fixpointtemp.txt

trialstarts = load('fixpointtemp.txt');
% fixp.t = temp(:,1)/1000 - E.start;
% fixp.pos = atand((screen.width*temp(:,2)/screen.pixelwidth)/screen.dist) - atand(screen.width/screen.dist)/2;
% % plot(fixp.t, fixp.pos,'-', 'DisplayName', 'fixpoint', 'XDataSource', 't', 'YDataSource', 'fixpoint'); figure(gcf)

