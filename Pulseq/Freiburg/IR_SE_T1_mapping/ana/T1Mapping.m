clc
clear

%% Received from Enlin Qian, Aug 2020
% Modified by Gehua Tong 
% For use in mapping water/fat bottles' T1 

%% Read in files
addpath(genpath('.'))

% Load the reconstructed images
% This .mat file can be found in the recon folder
load('../recon/T1_mapping_images_filtered.mat') ;
t1_images = images_filtered ;
image_data_final = mat2gray(squeeze(t1_images));
TI = [50, 75, 100, 125, 150, 250, 1000, 1500, 2000, 3000];
TI = TI./1000; % convert TI to s to allow better curve fitting performance
TR = (4.5).*ones(size(TI));
size_img = 128;
%% Define mask
disp('Please select a circular ROI covering the entire phantom:')
imagesc(squeeze(abs(image_data_final(:,:,3))))
addToolbarExplorationButtons(gcf)
axis equal tight
colormap gray

CircleStruc = drawcircle;
mask = createMask(CircleStruc);

close

image_data_final = image_data_final.*mask;

%% curve fitting for each pixel
T1_map = zeros(size_img, size_img);
tic
for n1 = 1:size_img
    for n2 = 1:size_img
        if sum(squeeze(image_data_final(n1,n2,:))) ~= 0
            y_data = squeeze(image_data_final(n1, n2, :));
            [Val, Loc] = min(y_data);
            
            n3 = 1;
            
            y_data_opt1 = y_data;
            y_data_opt2 = y_data;
            
            n3 = 1;
            while n3<=Loc
                y_data_opt1(n3) = -y_data_opt1(n3); %to fix the abs value problem
                n3 = n3 + 1;
            end
            
            n3 = 1;
            while n3<Loc
                y_data_opt2(n3) = -y_data_opt2(n3);
                n3 = n3 + 1;
            end            
            [fitresult1, gof1] = createFitT1(TI, TR, y_data_opt1);
            [fitresult2, gof2] = createFitT1(TI, TR, y_data_opt2);
            if gof1.sse < gof2.sse
                T1_map(n1, n2) = fitresult1.b;
            else
                T1_map(n1, n2) = fitresult2.b;
            end
                
            disp ((n1-1)*size_img+n2)
        end
    end
end
elapsedTime = toc;
save('T1_map_filtered.mat','T1_map')
%%
figure ;
imagesc(T1_map);colormap hot; axis equal tight;caxis([0 5]);addToolbarExplorationButtons(gcf);colorbar
title('Filtered T1 map (seconds)'); axis off

set(gca, 'color', 'none') ;
exportgraphics(gcf,'T1_map_filtered.png') ;