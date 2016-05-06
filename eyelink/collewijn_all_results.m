%% find data

D = 'results/'; % directory with results of process_all_asc, put processed data here.

F = dir([D '*.mat']);
nF = size(F,1);


%% process data

for idx = 1:nF % process each file in the directory D
    filename = [D F(idx).name];
    disp(filename)
    collewijn(filename,true);
    disp('done.')
end