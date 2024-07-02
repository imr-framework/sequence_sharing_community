%% Reconstruct T2 mapping images 
clear; clc 

k=13
volume = zeros(128, 512, 24);
% for k = 1:24
    fileName = sprintf('dicom80ms/series00700#000%02d.dcm', k);
    [spect map] = dicomread(fileName); 
    size(spect);
    spect80ms = squeeze(spect);
    % volume80ms(:,:,k) = spect;
% end

% volume60ms = zeros(128, 128, 24);
% for k = 1:24
    fileName = sprintf('dicom60ms/series00900#000%02d.dcm', k);
    [spect map] = dicomread(fileName); 
    size(spect);
    spect60ms = squeeze(spect);
    % volume60ms(:,:,k) = spect;
% end

% volume40ms = zeros(128, 128, 24);
% for k = 1:24
    fileName = sprintf('dicom40ms/series01000#000%02d.dcm', k);
    [spect map] = dicomread(fileName); 
    size(spect);
    spect40ms = squeeze(spect);
    % volume40ms(:,:,k) = spect;
% end

% volume20ms = zeros(128, 128, 24);
% for k = 1:24
    fileName = sprintf('dicom20ms/series01100#000%02d.dcm', k);
    [spect map] = dicomread(fileName); 
    size(spect);
    spect20ms = squeeze(spect);
    % volume20ms(:,:,k) = spect;
    slice = cat(3, spect80ms, spect60ms, spect40ms, spect20ms)
    % volume(:,:,k) = slice;
% end

volume = cat(3, spect80ms, spect60ms, spect40ms, spect20ms)
montage(mat2gray(slice))
title('T2 mapping images')
save('T2_mapping_images_reconstructed.mat','slice')


% %The first 128 excitations should not be used 
% load('T2_mapping_raw_data.mat') % Find in acq. folder
% kk = reshape(data,128,20,23,256); 
% kk1 = kk(:,:,:,129:end); 
% kk1 = permute(kk1,[1,4,2,3]); 
% 
% for c = 1:20
%     for q = 1:23
%         im(:,:,c,q) = fftshift(ifft2(kk1(:,:,c,q)));
%     end
% end
% images = squeeze(sqrt(sum(abs(im).^2,3)));
% montage(mat2gray(images))
% title('T2 mapping images')
% save('T2_mapping_images_reconstructed.mat','images')