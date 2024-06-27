
%% Received from Enlin Qian, Aug 2020
% Modified by TTFernandes
% For use in mapping water/fat bottles' T1 
 
clc
clear
%% 1 - Load Raw data from Siemens
raw_file_path  = 'D:\Tiago\Trabalho\2021_2025_PhD\Projects\Reproducibility\Data\IRSE_T1_mapping_v2\Scanner';
dataOutput     = 'D:\Tiago\Trabalho\2021_2025_PhD\Projects\Reproducibility\Data\IRSE_T1_mapping_v2\Reconstruction';

addpath(genpath('D:\Tiago\Trabalho\2021_2025_PhD\Projects\Reproducibility\Tools\developer_main_site\IRSE_T1_mapping\ana'))

%% Read in files
cd(dataOutput)

% Load the reconstructed images
% This .mat file can be found in the recon folder
load('T1_IRSE_images_forQuantit_reconstructed.mat','images') 

image_data_final = mat2gray(squeeze(images));
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
fig = figure();
imagesc(T1_map);
colormap hot;
axis equal tight;
addToolbarExplorationButtons(gcf);

%write to file
cd(dataOutput)
saveas(fig,'T1_mapping.jpg');

%%caxis([0,5])
save('T1_map.mat','T1_map')

