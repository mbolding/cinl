function [powernii,phasenii,fftnii] = freqImg(nii,TR)
%% Usage: freqImg(name)
% fft in the time domain
% name is the name of the 4D nifti image.
% for retinotopy:
% collect data for cw and ccw rot wedges
% reverse the ccw in time and generate both phase maps
% the retinotopic maps appear at freq of cycle time / TR
% subtract the ccw from cw phase and divide by two to get 
% the phase lag subtract the phase lag from the average of 
% the cw and ccw maps.

%% init environment
powernii = nii;
phasenii = nii;
fftnii = nii;

fft_map = fft(nii.img,[],4); % how about 2^ceil(log2(size(nii.img,4))) ?

fftnii.img = fft_map;
fftnii.img(nii.img<0.10*max(nii.img(:))) = 0;

powernii.img = fft_map.*conj(fft_map)/size(fft_map,4);
powernii.img(nii.img<0.10*max(nii.img(:))) = 0;

phasenii.img = angle(fft_map);
phasenii.img(nii.img<0.10*max(nii.img(:))) = 0;

powernii.hdr.dime.pixdim(5) = 1; 
phasenii.hdr.dime.pixdim(5) = 1; 
fftnii.hdr.dime.pixdim(5) = 1; 

return
