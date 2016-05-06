function measreadimage()
ShowFigs = 1;

% read one image
[RawData,LineMax,SliceMax] = readRaw('meas.out',ShowFigs);
% write procpar file
writeProcpar(LineMax,SliceMax);

%% Convert raw data to out data
% raw data is RawData(ro,pe,slices) in complex format
% out data is OutData(ro,pe,receiver,slice,B0) in wiht re and im alternated
% in ro row
OutData = zeros(LineMax*2,LineMax,1,SliceMax,1);
OutData(1:2:end,:,1,:,1) = real(RawData);
OutData(2:2:end,:,1,:,1) = imag(RawData);
% OutData = OutData*(32000/max(OutData(:))); % scale to write out as ints
%% write fid file
fp1=fopen('fid','w','b'); 
% totreads = 2*reads;
% totreads = res * 2;
% pevalues = zeros(1,res);
% data = zeros(totreads,res,rcvrs,slices,B0s);
B0s = 1;
rcvrs = 1;
catheader(fp1,1);
for a=1:LineMax
    for d=1:rcvrs
        catheader(fp1,2);
        for b=1:B0s
            for c=1:SliceMax
                % temp(1:totreads) = fread(fp1,totreads,'int');
                % data(1:totreads,a,d,c,b) = temp(1:totreads);
                fwrite(fp1,OutData(:,a,d,c,b),'float')
            end
        end
    end
end

fclose(fp1);

!mv fid procpar Scout.fid/

%% reread to test
fp2 = fopen('Scout.fid/fid','r','b');
stripheader(fp2,1);
totreads = LineMax*2;
InData = zeros(totreads,LineMax,rcvrs,SliceMax,B0s);
for a=1:LineMax
    for d=1:rcvrs
        stripheader(fp1,2);
        for b=1:B0s
            for c=1:SliceMax
                temp(1:totreads) = fread(fp2,totreads,'float');
                InData(1:totreads,a,d,c,b) = temp(1:totreads);
            end
        end
    end
end

%% plot it
if(ShowFigs==1)
    FigPos = 0;
    for idx = 1:SliceMax
        FigPos=FigPos+1;
        subplot(3,SliceMax,FigPos+SliceMax*2)
        imagesc(abs(log(InData(2:2:end,:,1,idx,1))));
        axis image
    end
end

return

function [RawData,LineMax,SliceMax] = readRaw(measfilename,ShowFigs)
% short example demonstrating the use of measread
% use e.g. with the MDH data from the simple ICE examples on the IDEA home
% page
% call the function, data and MDH are in matlab format
if exist('MeasRead','file')
    [mdh,data]=MeasRead(measfilename); % a windows .dll, see readme.txt
else
    load testData2Lphantom
end
% ShowFigs=1; % set to 1 to show images and anything else not to.
% strip the additional ADC at the end
mysize=size(data);
data=data(1:mysize(1),1:mysize(2)-1);
mysize=size(data);
mdh=mdh(1:mysize(2));
% example showing how to access the data in the mdh structure
% (Maybe the selection of structs was not so smart after all,
% now we have to convert the elements of the struct into cells before we
% can use them...)

% first we read the wanted attribute into cells
[Y{1:mysize(2)}] = deal(mdh.CurSlice);
% then we convert the cell into a matrix
% Careful: before reusing the generated matrix, it has to be reformated (is
% in vector form right now i.e. <1xmysize(1)>
Slice = cell2mat(Y);
Slices = unique(Slice)+1;

[Y{1:mysize(2)}] = deal(mdh.CurAcqu);
Acqu = cell2mat(Y);
Acqs = unique(Acqu);

[Y{1:mysize(2)}] = deal(mdh.CurLine);
Line = cell2mat(Y);
LineMax = unique(max(Line)+1);

% if (max(M) > 0)
%     sprintf('result may be wrong, more than one coil used')
% end
% now we fourier transform the data
% of course in reality we have to sort the data first according to the MDH
% entries, the task which is usually done by the ICE program. Of course in
% matlab this can be done easily with the help of indices, sorting and
% comparing indices (find), but who am I to tell you this ;-)
%(e.g.: imagesc(abs(fft2(data(:,find(M)))))  to reconstruct just one coil)

%% repack in slice order
SliceMax=max(Slices);
RawData=zeros(LineMax,LineMax,SliceMax);
[~,IX]=sort([2:2:SliceMax 1:2:SliceMax]); % all of the even slices then the odd
Slices = Slices(IX);
fprintf('Slices =');disp(Slices)
fprintf('Acqs =' );disp(Acqs)
fprintf('Lines =' );disp(LineMax)
clf
FigPos = 0;
for idx = Slices
    FigPos = FigPos + 1;
    slicedata = data(:,(Slice==(idx-1) & Acqu==0));  % pick a slice and acq number
    realdata = slicedata(1:2:end,:);
    imagdata = 1i*slicedata(2:2:end,:);
    slicedata = (realdata + imagdata);
    RawData(:,:,FigPos) = slicedata;
    if(ShowFigs==1)
        fftdata=fftshift(fft2(fftshift(RawData(:,:,FigPos))));
        subplot(3,SliceMax,FigPos)
        imagesc(abs(fftdata));
        axis off
        axis image
        subplot(3,SliceMax,FigPos+SliceMax)
        imagesc(angle(fftdata));
        axis off
        axis image
    end
end
return

function writeProcpar(LineMax,SliceMax)
% image parameters FIXME, need to read from meas.asc
lpe = 19.2; % pe FOV in cm
sfrq = 246.0; % scanner freq
thk = 2; % slice thickness in mm
gap = 8; % gap in mm
res = LineMax;
numSlices = SliceMax;
%% open procpar file for writing
fp = fopen('procpar','w');

%% write out a minimal procpar file for reading by shim code
fprintf(fp,'sfrq 1 1 1000000000 0 0 2 1 11 1 64 \n'); % FIXME why was this 400 at 4.7T? Should be what at 3T?
fprintf(fp,'1 %f  \n',sfrq);
fprintf(fp,'0  \n');
fprintf(fp,'theta 1 1 1000000 -1000000 0 2 1 8 1 64 \n'); % angulation of slab
fprintf(fp,'1 0  \n');
fprintf(fp,'0  \n');
fprintf(fp,'psi 1 1 1000000 -1000000 0 2 1 8 1 64 \n');
fprintf(fp,'1 0  \n');
fprintf(fp,'0  \n');
fprintf(fp,'phi 1 1 1000000 -1000000 0 2 1 8 1 64 \n');
fprintf(fp,'1 0  \n');
fprintf(fp,'0  \n');
fprintf(fp,'pss0 1 1 9.99999984307e+17 -9.99999984307e+17 0 2 1 0 1 64 \n'); % center of acq slab
fprintf(fp,'1 0  \n');
fprintf(fp,'0  \n');
fprintf(fp,'lpe 1 1 100 2 0 2 1 0 1 64 \n'); % length of pe FOV in cm
fprintf(fp,'1 %f  \n',lpe);
fprintf(fp,'0  \n');
fprintf(fp,'nv 1 1 1000000 0 1 2 1 9 1 64 \n'); % phase encodes
fprintf(fp,'1 %d  \n',res);
fprintf(fp,'0  \n');
fprintf(fp,'ns 1 1 1000000 0 1 2 1 9 1 64 \n'); % number of slices
fprintf(fp,'1 %d  \n',numSlices);
fprintf(fp,'0 \n');
fprintf(fp,'thk 1 1 1000000 -1000000 0 2 1 0 1 64 \n'); % thicknes in mm
fprintf(fp,'1 %f  \n',thk);
fprintf(fp,'0  \n');
fprintf(fp,'gap 1 1 9.99999984307e+17 -9.99999984307e+17 0 2 1 0 1 64 \n'); % gap in mm
fprintf(fp,'1 %f  \n',gap);
fprintf(fp,'0 \n');
fprintf(fp,'b0delay 1 1 9.99999984307e+17 -9.99999984307e+17 0 2 1 0 1 64 \n'); % initial delay in ms
fprintf(fp,'1 0.001  \n');
fprintf(fp,'0  \n');
fprintf(fp,'b0times 1 1 9.99999984307e+17 -9.99999984307e+17 0 2 1 0 1 64 \n'); % incremental delays
fprintf(fp,'1 5  \n');
fprintf(fp,'0  \n');
fprintf(fp,'np 7 1 10000000 32 2 2 1 11 1 64 \n'); % number of k-space points per read * 2 (because complex val)
fprintf(fp,'1 %d  \n',res*2);
fprintf(fp,'0  \n');
fprintf(fp,'rcvrs 4 2 4 0 0 2 1 1 1 64 \n');
fprintf(fp,'1 "y" \n');
fprintf(fp,'2 "n" "y"  \n');
fprintf(fp,'seqcon 2 2 0 0 0 2 1 9 1 64 \n');
fprintf(fp,'1 "ccsnn" \n');
fprintf(fp,'0  \n');

%% close procpar file
fclose(fp);
return

function catheader(fp1,a)

if (a==1)
   fwrite(fp1,zeros(32,1),'char*1');
end

if (a==2)
   fwrite(fp1,zeros(28,1),'char*1');
end
return
    