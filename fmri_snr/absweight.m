function wrnii = absweight(nii)
%% weight resp with abs val
wrnii = nii;
wr = wrnii.img;
wr = abs(wr) .* real(wr);
wrnii.img = wr;

return