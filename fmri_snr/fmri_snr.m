% function [s_snr,t_snr] = fmri_snr(workdir,glob)
% SNR calculator for fMRI images
% requires NIFTI toolbbox from mathworks download site
% http://www.google.com/search?rls=en&q=nifti+toolbox

%% init environment
old_dir=pwd;
cd(workdir)
% colormap hot
make_t_snr = 1; % flag to calculate mean and temporal snr
show_s_snr = 0; % flag to indicate whether to show spacial snr map
show_t_snr = 1; % flag to indicate whether to show temporal snr map

%% load images
mydir = dir(glob);
disp(mydir(1).name)
ana_vols_count=size(mydir,1);
myvols = load_nii(mydir(1).name);
mysinglevol = load_nii(mydir(1).name,1);
voldim=size(myvols.img);
numvoldim=size(voldim,2);
midslice=int16(voldim(2)/2);
switch numvoldim
    case 3 % 3D files
        myslice = mysinglevol.img(:,midslice,:);
        if ana_vols_count == 1  % 1 volume
            disp('only one volume loaded')
            make_t_snr = 0;
        elseif ana_vols_count < 10 % less than 10 volumes
            mysinglevol = load_nii(mydir(5).name); 
            myvols4d = zeros([voldim ana_vols_count]);
            for k = 1:ana_vols_count
                mytempvol = load_nii(mydir(k).name);
                myvols4d(:,:,:,k) = mytempvol.img;
            end
        else % 10 or more volumes
           mysinglevol = load_nii(mydir(10).name); 
           myvols4d = zeros([voldim ana_vols_count]);
           for k = 1:ana_vols_count
               mytempvol = load_nii(mydir(k).name);
               myvols4d(:,:,:,k) = mytempvol.img;
           end
        end
    case 4 % 4Dfiles
        myslice = mysinglevol.img(:,midslice,:);
        myvols4d = myvols.img;
%         mysinglevol.img = mysinglevol.img(:,:,:);
    otherwise
        error('wtf? dimintions of image are bogus')
end
myslice=squeeze(myslice);
cd(old_dir)



%% calc image SNR
maxsig = max(mysinglevol.img(:));
mysignal=mysinglevol.img;mysignal(mysinglevol.img<(0.3*maxsig)) = NaN; 
mynoise=mysinglevol.img;mynoise(mysinglevol.img>(0.03*maxsig)) = NaN; 
mynoiseest=mean(mynoise(:))/sqrt(pi/2);
s_snr = mean(mysignal(:)) / mynoiseest;
myspacialsnrmap = mysinglevol.img/mynoiseest;
myspacialsnrvol.img = myspacialsnrmap;

%% calc temporal SNR and mean signal
if make_t_snr == 1
    mymeansignalmap = mysinglevol;
    mytemporalsnrmap = mysinglevol;
    mymeansignalmap.img = mean(myvols4d,4);
    mytemporalsnrmap.img = mymeansignalmap.img ./ std(myvols4d,0,4);
end



%% display results
if show_s_snr == 1
    figure(1)
    subplot(2,2,1)
    imagesc(squeeze(mysignal(:,midslice,:)))
    title('signal pixels (pixels>30% of max)')
    subplot(2,2,2)
    imagesc(squeeze(mynoise(:,midslice,:)))
    title('noise (pixels<3% of max)')
    subplot(2,2,3)
    imagesc(squeeze(myspacialsnrmap(:,midslice,:)))
    title('spacial snr map')
    myspacialsnrvol = mysinglevol;

    myspacialsnrvol.img = myspacialsnrmap;
    view_nii(myspacialsnrvol);
end

if show_t_snr == 1 && make_t_snr == 1;
    view_nii(mytemporalsnrmap);
end


%% clean up
cd(old_dir)
