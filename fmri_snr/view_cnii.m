function view_cnii(nii)
%% display complex nii

absnii = nii;
angnii = nii;

absnii.img = abs(absnii.img);
angnii.img = angle(angnii.img);

view_nii(absnii);
view_nii(angnii);

return