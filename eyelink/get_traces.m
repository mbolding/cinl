function E = get_traces(filename)
% E = get_traces(filename)
% loads traces from converted eyelink edf files
% assumes samples are in 'samples' subdir
% assumes events are in 'events' subdir
% needs shell commands so should run on osx or linux, but will need mods 
% for windows.
%
% event conversion example:
% edf2asc_s -e -p events rawdata/*/*.edf
% sample conversion:
% edf2asc_s -s -sh -p samples rawdata/1005/*.edf 
% 
% E.L left eye
% E.R right eye
% E.T target
%
% mbolding@uab.edu 22 Feb 2011

if ~exist('filename','var') % ask for filename if not supplied on command line
    [filename] = uigetfile('*.asc');
end

%% screen FIXME read these out of event file instead.
screen.width = 40;
screen.dist = 100;
screen.pixelwidth = 800;
sample.freq = 1000;

[~,E.name,] = fileparts(filename) ;

%% load samples
samplefilename = ['samples/' filename];
fid = fopen(samplefilename);
frewind(fid) ; 
A = textscan(fid,'%f %f %f %f %f %f %f %f','CollectOutput', 1, 'treatAsEmpty', {'.','I'});

%% calculate traces
E.start = min(A{1,1}(1:10,1))/sample.freq;
E.t = A{1,1}(:,1)/sample.freq - E.start;
E.L.x = atand((screen.width*A{1,1}(:,2)/screen.pixelwidth)/screen.dist) - atand(screen.width/screen.dist)/2;
E.R.x = atand((screen.width*A{1,1}(:,5)/screen.pixelwidth)/screen.dist) - atand(screen.width/screen.dist)/2;
E.V.x = (E.L.x - E.R.x)/2;

%% load target motion
copyfile(['events/' filename], 'temp.asc')
!grep FIXPOINT temp.asc  | awk '{ print $2 " " $11  }' > fixpointtemp.txt
temp = load('fixpointtemp.txt');
E.T.t = temp(:,1)/sample.freq - E.start;
E.T.x = atand((screen.width*temp(:,2)/screen.pixelwidth)/screen.dist) - atand(screen.width/screen.dist)/2;
!grep TRIALID temp.asc  | awk '{ print $2 }' > fixpointtemp.txt
E.trialstarts = load('fixpointtemp.txt');
E.trialstarts = E.trialstarts/sample.freq - E.start;
!grep TRIAL_RESULT temp.asc  | awk '{ print $2 }' > fixpointtemp.txt
E.trialends = load('fixpointtemp.txt');
E.trialends = E.trialends/sample.freq - E.start;

%% load some parameters
[~,E.trialype]=system('grep BLOCKSYNC temp.asc | awk ''{ print $4 }''');

fclose('all');
