%% Reconstruct T1 mapping images 
clear; clc 
TI = [50,75,100,125,150,250,1000,1500,2000,3000];
images = zeros(128,128,10);
images_filtered = zeros(128,128,10);
wk = hamming(128,'symmetric')'; 
wk2d = wk(:)*wk(:).'; % Create 2D window
imspace = zeros(size(images)) ;
for u = 1:10
    load(sprintf('../acq/T1_mapping_raw_TI%dms',TI(u))); % Find in acq. folder
    kspace = data; 
    for c = 1:20 
        imspace(:,:,c) = ifftshift(ifft2(ifftshift(squeeze(kspace(:,c,:)))));
    end
    images(:,:,u) = sqrt(sum(abs(imspace).^2,3)); 
end
%% 
figure ;
montage(mat2gray(images))
title('T1 mapping images')
set(gca, 'color', 'none') ;
exportgraphics(gcf,'T1_mapping_images_reconstructed.png') ;
save('T1_mapping_images_reconstructed.mat','images')

%%
for u = 1:10
    load(sprintf('../acq/T1_mapping_raw_TI%dms',TI(u))); % Find in acq. folder
    kspace = data; 
    for c = 1:20 
        imspace(:,:,c) = fftshift(ifft2(wk2d .* squeeze(kspace(:,c,:))));
    end
    images_filtered(:,:,u) = sqrt(sum(abs(imspace).^2,3)); 
end
%% 
figure ;
montage(mat2gray(images_filtered))
title('T1 mapping images')
set(gca, 'color', 'none') ;
exportgraphics(gcf,'T1_mapping_images_filtered.png') ;
save('T1_mapping_images_filtered.mat','images_filtered')