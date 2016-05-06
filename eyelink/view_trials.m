function view_trials(trials)
if ~exist('trials','var')
    [filename,pathname] = uigetfile;
    load([pathname filename])
end
% view trials
numTrials = size(trials,2);
for i=1:numTrials
    figure(i)
    numSac_L=size(trials(i).sac_L,1);
    if numSac_L > 0
        a=mean(trials(i).sac_L,1);
        meanDur_L=a(3);
        meanAmp_L=a(8);
        meanVel_L=a(9);
    else
        trials(i).sac_L = [0 0 0 0 0 0 0 0 0];
        meanDur_L=0;
        meanAmp_L=0;
        meanVel_L=0;
    end
    numSac_R=size(trials(i).sac_R,1);
    if numSac_R > 0
        a=mean(trials(i).sac_R,1);
        meanDur_R=a(3);
        meanAmp_R=a(8);
        meanVel_R=a(9);
    else
        trials(i).sac_R = [0 0 0 0 0 0 0 0 0];
        meanDur_R=a(3);
        meanAmp_R=a(8);
        meanVel_R=a(9);
    end
    subplot(2,1,1), plot(trials(i).eye(:,1),trials(i).eye(:,2), 'b',trials(i).target(:,1),trials(i).target(:,2),'k:',trials(i).sac_L(:,1),trials(i).sac_L(:,4),'g*',trials(i).sac_L(:,2),trials(i).sac_L(:,6),'r*');
    xlabel('Time (msec)'), ylabel('Eye position (pixels)'), title('Horizontal Eye Movements');
    legend('Hori Eye Position','Hori Target Position','Start Sac','End Sac');
    ylim([0 800])
    ax=axis;
    if numSac_L>=numSac_R
        s=['#Sac=' num2str(numSac_L) '; aveDur=' num2str(meanDur_L) ' msec; aveAmp=' num2str(meanAmp_L) ' deg; aveVel=' num2str(meanVel_L) ' deg/sec'];
    else
        s=['#Sac=' num2str(numSac_R) '; aveDur=' num2str(meanDur_R) ' msec; aveAmp=' num2str(meanAmp_R) ' deg; aveVel=' num2str(meanVel_R) ' deg/sec'];
    end
    text(500,ax(4)-20,s);
    subplot(2,1,2), plot(trials(i).eye(:,1),trials(i).eye(:,3), 'b',trials(i).target(:,1),trials(i).target(:,3),'k:',trials(i).sac_L(:,1),trials(i).sac_L(:,5),'g*',trials(i).sac_L(:,2),trials(i).sac_L(:,7),'r*');
    xlabel('Time (msec)'), ylabel('Eye position (pixels)'), title('Vertical Eye Movements');
    legend('Vert Eye Position','Vert Target Position','Start Sac','End Sac');
    ylim([0 600])
    %         pause
end
