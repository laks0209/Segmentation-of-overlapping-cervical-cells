function out=maxima(I)
% finding maxima
max = imextendedmax(I, 5);
max = imclose(max, strel('disk',3));
max = imfill(max, 'holes');
out = bwareaopen(max, 2);
end