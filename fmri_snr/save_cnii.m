function save_cnii(nii,name)
%% display complex nii

absnii = nii;
angnii = nii;

absnii.img = abs(absnii.img);
angnii.img = angle(angnii.img);

absnii.hdr.dime.pixdim(5) = 1; % fourth dimension step size
angnii.hdr.dime.pixdim(5) = 1; % fourth dimension step size

save_nii(absnii,['abs_' name])
save_nii(angnii,['ang_' name])

return