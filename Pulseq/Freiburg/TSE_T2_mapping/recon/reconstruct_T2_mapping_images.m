%% Reconstruct T2 mapping images 
% clear; clc 
%The first 128 excitations should not be used 
load('../acq/T2_mapping_raw_data.mat') % Find in acq. folder
kk = reshape(data,128,20,23,128); 
kk1 = kk ; 
kk1 = permute(kk1,[1,4,2,3]); 
wk = hamming(128,'symmetric')'; 
wk2d = wk(:)*wk(:).'; % Create 2D window
im = zeros(size(kk1)) ;
for c = 1:18
    for q = 1:23
        im(:,:,c,q) = ifftshift(ifft2(ifftshift(kk1(:,:,c,q))));
    end
end
images = squeeze(sqrt(sum(abs(im).^2,3)));
figure ;
montage(mat2gray(images))
title('T2 mapping images')
set(gca, 'color', 'none') ;
exportgraphics(gcf,'T2_mapping_images_reconstructed.png') ;

save('T2_mapping_images_reconstructed.mat','images')

for c = 1:18
    for q = 1:23
        im(:,:,c,q) = ifftshift(ifft2(ifftshift(kk1(:,:,c,q).*wk2d)));
    end
end
images_filtered = squeeze(sqrt(sum(abs(im).^2,3)));
figure ;
montage(mat2gray(images_filtered))
set(gca, 'color', 'none') ;
exportgraphics(gcf,'T2_mapping_images_filtered.png') ;

title('filtered T2 mapping images')
save('T2_mapping_images_filtered.mat','images_filtered')