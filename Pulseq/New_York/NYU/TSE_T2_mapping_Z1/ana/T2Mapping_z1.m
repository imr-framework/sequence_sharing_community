clc; clear 

%% Read in files
addpath(genpath('.'))
% The filtered images can be found in the "recon" folder
disp('')
load('T2_mapping_images_reconstructed.mat','slice')
TE = 20*(1:4)./1000;
TR = 2.5.*ones(size(TE));
size_img = 128;
image_data_final = mat2gray(slice); 
% image_data_final = image_data_final.*1000; % for better curve fitting

%% Define mask
disp('Please select 4 circular ROIs covering the entire phantom:')
imagesc(squeeze(abs(image_data_final(:,:,3))))
addToolbarExplorationButtons(gcf)
axis equal tight
colormap gray

CircleStruc1 = drawcircle;
CircleStruc2 = drawcircle;
CircleStruc3 = drawcircle;
CircleStruc4 = drawcircle;
mask = createMask(CircleStruc1) + createMask(CircleStruc2) + createMask(CircleStruc3) + createMask(CircleStruc4);

close

image_data_final = image_data_final.*mask;

%% curve fitting for each pixel
T2_map = zeros(size_img, size_img);
% Only use TE # m - 23 
TE_fin = TE(1:end);
for n1 = 1:size_img
    for n2 = 1:size_img
       nnz(image_data_final(n1,n2,:))
       if nnz(image_data_final(n1,n2,:))== 4
            y_data = squeeze(image_data_final(n1, n2, :));
            y_data = y_data(1:end);
            [fitresult, gof] = createFitT2(TE_fin, y_data); 
            T2_map(n1, n2) = fitresult.b;
            disp ((n1-1)*141+n2)
       end
    end
end
%% Display
imagesc(T2_map);colormap hot; axis equal tight;caxis([1 6]);addToolbarExplorationButtons(gcf);colorbar
title('T2 map'); axis off

