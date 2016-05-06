function trials = read_el_sp(filename)
% read_el_sp - 
% use this to convert eyelink asc data to the .mat files we use for
% analysis. called by process_all_asc_data
progPath = fileparts(which(mfilename));
resultPath=[pwd filesep 'results' filesep];

trials=struct('eye',{}, 'target',{}, 'sac_L',{}, 'sac_R',{});

if ~exist('filename','var')
    [filename,pathname] = uigetfile('*.asc');
    filename = [pathname filesep filename];
end
fileloc = filename;
txt=fileread(fileloc);

%% collect experiment info

fid = fopen(fileloc);
% t=txt(1:10000);
fprintf('%% read eyelink data\ncollect experiment info');
for idx = 1:100
        if mod(idx,5)==0 % print one dot each 5 lines
            fprintf('.');
        end
    oneline = fgetl(fid);
    %     disp(oneline)
    if strfind(oneline,'CONVERTED FROM')
        [~,~,~,s]=regexpi(oneline,'[\w\.]*\.edf');
        ascFile=s{1};
        %         t=remain;
    elseif strfind(oneline,'Subject ID:')
        s = strfindRev( oneline,':',length(oneline) );
        sID=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Date:')
        s = strfindRev( oneline,':',length(oneline) );
        testDate=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Program Used:')
        s = strfindRev( oneline,':',length(oneline) );
        progUsed=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'View Distance:')
        s = strfindRev( oneline,':',length(oneline) );
        viewDist=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Number Calibration Points:')
        s = strfindRev( oneline,':',length(oneline) );
        numCalPoints=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Target Size:')
        s = strfindRev( oneline,':',length(oneline) );
        targetSize=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Target Color:')
        s = strfindRev( oneline,':',length(oneline) );
        targetColor=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Background:')
        s = strfindRev( oneline,':',length(oneline) );
        background=strtrim(s(2:end));
    elseif strfind(oneline,'Pursuit Waveform: ')
        s = strfindRev( oneline,':',length(oneline) );
        waveform=strtrim(s(2:end));
    elseif strfind(oneline,'Pseudo-Random Band: ')
        s = strfindRev( oneline,':',length(oneline) );
        pseudoRandBand=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Average Speed:')
        s = strfindRev( oneline,':',length(oneline) );
        targetSpeed=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Pursuit Amplitude:')
        s = strfindRev( oneline,':',length(oneline) );
        amplitude=strtrim(s(2:end));
    elseif strfind(oneline,'Pursuit Direction:')
        s = strfindRev( oneline,':',length(oneline) );
        direction=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Period:')
        s = strfindRev( oneline,':',length(oneline) );
        period=strtrim(s(2:end));
    elseif strfind(oneline,'Frequency:')
        s = strfindRev( oneline,':',length(oneline) );
        targetFrequency=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Number of Periods:')
        s = strfindRev( oneline,':',length(oneline) );
        numPeriod=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Trial Duration:')
        s = strfindRev( oneline,':',length(oneline) );
        trialDuration=strtrim(s(2:end));
        %         t=remain;
    elseif strfind(oneline,'Number of Trials:')
        s = strfindRev( oneline,':',length(oneline) );
        nT=strtrim(s(2:end));
        %t=remain;
        fprintf('\n');
    elseif strfind(oneline,'Target Size:')
        s = strfindRev( oneline,':',length(oneline) );
        targetSize=strtrim(s(2:end));
        %t=remain;
        fprintf('\n');
    elseif strfind(oneline,'Bakground Check Size:')
        s = strfindRev( oneline,':',length(oneline) );
        checkSize=strtrim(s(2:end));
        %t=remain;
        fprintf('\n');
    elseif strfind(oneline,'START')
        collectedData = textscan(oneline,'%s');
        collectedData = collectedData{1};
        %t=remain;
        fprintf('%s \n',collectedData{:});
        break;
    elseif strfind(oneline,'RECORD')
        temp = sscanf(oneline,'MSG	%d !MODE RECORD %s %d %d %d');
        fprintf('found start of recording. %d Hz\n',temp(3));
        sample_rate = temp(3);
    else
        %         t=remain;
    end
end
fclose(fid);


txt=fileread(fileloc);

%% determine the number of trials
numTrials=1;
fprintf('\nfind trials');
while 1
    fprintf('.');
    if strfind(txt,['TRIALID ' num2str(numTrials)])
        numTrials=numTrials+1;
    else
        fprintf(' %d \n',numTrials - 1);
        break;
    end
end
numTrials=numTrials-1;

%% parse trials
for trial=1:numTrials
    fprintf('trial %d',trial);
    k1=strfind(txt,['TRIALID ' num2str(trial) ' SP']);
    if isempty(k1)
        k1=strfind(txt,['TRIALID ' num2str(trial)]);
    end
    t=txt(k1:end);
    k1=strfind(t,'SYNCTIME');
    if isempty(k1)
        k1=strfind(t,'BLOCKSYNC');
    end
    % find stimulus starting onset time
    s = strfindRev( t,'MSG',k1(1) );
    C = textscan(s ,'%s');
    stimulusOnset=str2double(C{1}{2});
    % extract data of one trial
    k2=strfind(t,['TRIALID ' num2str(trial+1) ' SP']);
    if isempty(k2)
        k2=strfind(t,['TRIALID ' num2str(trial+1) ]);
    end
    if isempty(k2)
        t=t(k1(1):end);
    else
        t=t(k1(1):k2);
    end
    % get lines of data into a struct
    lines=struct('line',{});
    lineCount=0;
    %     while 1
    %         [oneline remain] = strtok(t, char(13));
    %         if lineCount>0
    %             lines(lineCount).line=oneline;
    %         end
    %         lineCount=lineCount+1;
    %         if length(remain)>1
    %             t=remain;
    %         else
    %             break;
    %         end
    %     end
    Lines = textscan(t,'%s','delimiter',char(13));
    Lines = Lines{1};
    % get eye positions and target positions & sac
    numLines=size(Lines,1);
    eyePos=[];  % [time x y]
    targetPos=[];   % [time x y]
    saccades_L=[];   % [stime etime dur spx spy epx epy amp vel]
    saccades_R=[];   % [stime etime dur spx spy epx epy amp vel]
    for i=1:numLines
        if mod(i,1000)==0 % print one dot each 1000 lines
            fprintf('.');
        end
        L=Lines{i};
        if length(L)> 1 && double(L(2))>=48 % each line starts with a char(10). Make sure the line is not otherwise empty
            %             c=strParse(L,char(32),char(9));
            C = textscan(L,'%s');
            % if sum(isletter(C{1}{1}))==0 % the first token of the line are not letters
            % eyePos=[eyePos; [str2double(C{1}{1})-stimulusOnset str2double(C{1}{2}) str2double(C{1}{3})] ];
            if sum(isletter(C{1}{1}))==0 % the first token of the line are not letters
                eyeTemp = sscanf(L,'%f');
                if length(eyeTemp)<3
                    eyeTemp(2:3)=NaN;
                end
                % eyePos=[eyePos; [str2double(C{1}{1})-stimulusOnset str2double(C{1}{2}) str2double(C{1}{3})] ];
                eyePos=[eyePos; [eyeTemp(1)-stimulusOnset eyeTemp(2) eyeTemp(3)] ];
            elseif strcmp(C{1}{1}, 'MSG') && strcmp(C{1}{3},'TARGET_POS')
                targetTemp = sscanf(L,'MSG %f TARGET_POS %f %f %f %f %f %f');
                targetPos=[targetPos; [targetTemp(1)-stimulusOnset targetTemp(2:3)' ] ];
                %                 targetPos=[targetPos; [str2double(C{1}{2})-stimulusOnset str2double(C{1}{4}) str2double(C{1}{5})]];
            elseif strcmp(C{1}{1}, 'MSG') && strcmp(C{1}{3},'!V') && strcmp(C{1}{4},'TARGET_POS')
%                 MSG	5412250 !V TARGET_POS TARG1 (831, 384) 1 1
                targetTemp = sscanf(L,'MSG %f !V TARGET_POS TARG1 (%f, %f)');
                targetPos=[targetPos; [targetTemp(1)-stimulusOnset targetTemp(2) targetTemp(3)] ];
                %                 targetPos=[targetPos; [str2double(C{1}{2})-stimulusOnset str2double(C{1}{4}) str2double(C{1}{5})]];
            elseif strcmp(C{1}{1}, 'ESACC')
                %ESACC <eye> <stime> <etime> <dur> <sxp> <syp> <exp> <eyp> <ampl> <pv>
                stime=str2double(C{1}{3})-stimulusOnset;
                etime=str2double(C{1}{4})-stimulusOnset;
                dur=str2double(C{1}{5});
                spx=str2double(C{1}{6});
                spy=str2double(C{1}{7});
                epx=str2double(C{1}{8});
                epy=str2double(C{1}{9});
                amp=str2double(C{1}{10});
                vel=str2double(C{1}{11});
                d=[stime etime dur spx spy epx epy amp vel];
                if strcmp(C{1}{2},'L')
                    saccades_L=[saccades_L; d];
                elseif strcmp(C{1}{2},'R')
                    saccades_R=[saccades_R; d];
                end
            end
        end
    end
    fprintf('\n');
    trials(trial).eye=eyePos;
    trials(trial).target=targetPos;
    trials(trial).sac_L=saccades_L;
    trials(trial).sac_R=saccades_R;
end
%% save processed data
of=[ascFile(1:length(ascFile)-3) 'mat'];

save([resultPath of],'trials','background','period','sample_rate','direction','targetFrequency','targetSize');

if strcmp(waveform,'Pseudo-random')
    save([resultPath of],'pseudoRandBand','-append');
end

if exist('checkSize','var')
    save([resultPath of],'checkSize','-append');
end
    

view_trials(trials);




