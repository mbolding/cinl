function show_traces(filename)
% showtraces(filename)  
% show traces from sample only file created with edf2asc
% event conversion example:
% edf2asc_s -e -p events rawdata/*/*.edf
% sample conversion:
% edf2asc_s -s -sh -p samples rawdata/1005/*.edf 


if ~exist('filename','var')
    [filename,pathname] = uigetfile('*');
end

fid = fopen([pathname filename]);
frewind(fid) ; 
A = textscan(fid,'%f %f %f %f %f %f %f %f','CollectOutput', 1, 'treatAsEmpty', {'.','I'});
plot(A{1,1}(:,1),A{1,1}(:,[2 4 5 7]));