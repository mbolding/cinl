function save_rinii(nii,name)
%% display complex nii as real and imag

realnii = nii;
imagnii = nii;

realnii.img = real(realnii.img);
imagnii.img = imag(imagnii.img);
realnii.hdr.dime.pixdim(5) = 1; % fourth dimension step size
imagnii.hdr.dime.pixdim(5) = 1; % fourth dimension step size

save_nii(realnii,['r_' name])
save_nii(imagnii,['i_' name])

return