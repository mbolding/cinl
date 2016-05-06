function respnii = filter_ret(name,freq)
%% fourier filter fMRI data
% filter_ret(name,freq)
% name is 4d nii file name
% freq is array of frequencies to keep
% respnii is 4d nii structure, in time domain.
% overwites "r_"name" and "i_"name

nii = load_nii(name);
freqnii = nii;
fft_map = fft(nii.img,[],4);
freqnii.img = fft_map;
freqnii.img(nii.img<0.10*max(nii.img(:))) = 0;
freqnii.hdr.dime.pixdim(5) = 1; % fourth dimension step size
filtnii = freqnii;
filtnii.img(:) = 0;
filtnii.img(:,:,:,freq) = freqnii.img(:,:,:,freq);
respnii = nii;
resp_map = ifft(filtnii.img,[],4);
respnii.img=resp_map;
save_rinii(respnii,name)