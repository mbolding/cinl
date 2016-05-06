function process_all_asc_data
% Data is prepared by first converting from .edf to asc using the GUI
% converter from SR Research. Next make three folders (asc_data, edf_data,
% results) and put the asc_data and edfs into their respective directories.
% Run script process_all_asc_data to preprocess and convert the asc data
% to .mat files. 
% The resulting .mat files in the directory 'results' can then be analyzed
% using collewijn or eyefit.



%% find data

D = 'asc_data/'; % directory with asc data, put converted data here.

F = dir([D '*.asc']);
nF = size(F,1);


%% process data

for idx = 1:nF % process each file in the directory D
    filename = [D F(idx).name];
    disp(filename)
    read_el_sp(filename);
end