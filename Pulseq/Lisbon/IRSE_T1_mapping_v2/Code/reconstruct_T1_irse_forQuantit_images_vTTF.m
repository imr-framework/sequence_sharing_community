clear; clc 

%% 0 - Addpath
addpath(genpath('D:\Tiago\Trabalho\2021_2025_PhD\Projects\qMRI_Joint\Code\matlabCode\Toolboxes\Read_dat\mapVBVD'))

%% 1 - Load Raw data from Siemens
% raw_file_path  = 'D:\Tiago\Trabalho\2021_2025_PhD\Projects\Reproducibility\Data\IRSE_T1_mapping\Scanner';
% dataOutput     = 'D:\Tiago\Trabalho\2021_2025_PhD\Projects\Reproducibility\Data\IRSE_T1_mapping\Reconstruction';

raw_file_path  = 'D:\Tiago\Trabalho\2021_2025_PhD\Projects\Reproducibility\Data\IRSE_T1_mapping_v2\Scanner';
dataOutput     = 'D:\Tiago\Trabalho\2021_2025_PhD\Projects\Reproducibility\Data\IRSE_T1_mapping_v2\Reconstruction';

cd(raw_file_path)
[p,n,e]         = fileparts(raw_file_path);
basic_file_path = fullfile(p,n);

TI = [50,75,100,125,150,250,1000,1500,2000,3000];
% TI = [50];
sizTI = size(TI,2);
data_unsorted = NaN(128,18,128,sizTI);

for u = 1:sizTI
    % revert to Siemens .dat file
    data_file_path = [basic_file_path '\IRSE_I',num2str(u) ,'_TI_', num2str(TI(u)),'.dat'];
    fprintf(['loading `' data_file_path '´ ...\n']);
    twix_obj = mapVBVD(data_file_path);
    if iscell(twix_obj)
        data_unsorted(:,:,:,u)  = twix_obj{end}.image.unsorted();
        seqHash_twix=twix_obj{end}.hdr.Dicom.tSequenceVariant;
    else
        data_unsorted(:,:,:,u) = twix_obj.image.unsorted();
        seqHash_twix=twix_obj.hdr.Dicom.tSequenceVariant;
    end
    
    if length(seqHash_twix)==32
        fprintf(['raw data contain pulseq-file signature ' seqHash_twix '\n']);
    end
end

%% 2 - Rearrange twix_object
[adc_len,channels,readouts,nImages]=size(data_unsorted);
data_coils_last = permute(data_unsorted, [1, 3, 2, 4]);

Nx      = adc_len;
Ny      = Nx;
kspace  = data_coils_last;

% Reorder slices and re-oriented
figure()
imagesc(squeeze(abs(data_coils_last(:,:,3,1))))


%% Reconstruct T1 mapping images 
images = zeros(128,128,nImages); 
for u = 1:nImages
    for c = 1:channels 
        imspace(:,:,c) = fftshift(ifft2(squeeze(kspace(:,:,c,u))));
    end
    images(:,:,u) = sqrt(sum(abs(imspace).^2,3)); 
end

%% 

% Display
clf(1) %create a clean figure (use clf only in debugging)

fig = figure(1);
h = montage(mat2gray(images));
title('T1 mapping images')
cd(dataOutput)
save('T1_mapping_images_reconstructed.mat','images')

%write to file
montage_IM = h.CData;
ImFileOut  = fullfile(dataOutput, 'T1 mapping images.png');
imwrite(montage_IM,ImFileOut);

% Save matrix
cd(dataOutput)
save('T1_IRSE_images_forQuantit_reconstructed.mat','images')
