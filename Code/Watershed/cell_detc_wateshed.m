clear all; close all; clc;
A = imread('stem-cells.jpg');
I = rgb2gray(A);
I = adapthisteq(I); 
I = imclearborder(I); 
I = wiener2(I, [3 3]); % denoising filter
th=graythresh(I); % global threshold
bw = im2bw(I, th); % binarization
bw2 = imopen(bw, strel('disk',2));
bw3 = bwareaopen(bw2, 100);
bw3_boundary = bwperim(bw3); % get boundary

% 'imoverlay' is written by Steven L. Eddins and I slightly modified it for
% our project. It overlays the edge detected.
overlay_1 = imoverlay(I, bw3_boundary, [1 .3 .3]);


% Discover putative cell centroids (maxima)
maxs=maxima(I); 
overlay_2 = imoverlay(I, bw3_boundary | maxs, [1 .3 .3]);


imcom_I = imcomplement(I); % get complement image
% adjust the image so that the background pixels and the extended maxima pixels are forced to be the only local minima in the image.
adj_I = imimposemin(imcom_I, ~bw3 | maxs);
wat = watershed(adj_I); % watershed
label_I = label2rgb(wat); % labeling
[wat, num] = bwlabel(wat);
bound = im2bw(wat, 1);
overlay_3 = imoverlay(I, bound, [0.3 .3 .3]);

figure; imshow(A);
figure; imshow(label_I);
figure; imshow(overlay_1); 
figure; imshow(overlay_2);
figure; imshow(overlay_3);