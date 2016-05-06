function view_rinii(nii)
%% display complex nii as real and imag

realnii = nii;
imagnii = nii;

realnii.img = real(realnii.img);
imagnii.img = imag(imagnii.img);

view_nii(realnii)
view_nii(imagnii)

return