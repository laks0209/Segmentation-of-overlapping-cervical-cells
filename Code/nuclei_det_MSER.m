clear all;

org = imread('frame011.png');
figure;imshow(org);
title('EDF image');
dup = org;


% MSER algorithm

regions = detectMSERFeatures(org);
[m,n] = size(regions);

for(i=1:m)
    [m1,n1] = size(regions(i,1).PixelList);
    if((m1>200)&&(m1<600))
    A1 = regions(i,1);
    end
end


% Detecting nuclei

k=1;
for(i=1:m)
    [m1,n1] = size(regions(i,1).PixelList);
    if((m1>200)&&(m1<550))
        A1(k,1) = regions(i,1);
        [m2,n2] = size(A1(k,1).PixelList);
        C = A1(k,1).PixelList;
        for(j=1:m2)
            dup(C(j,2),C(j,1))=0;
        end
        k=k+1;
    end
end
figure;imshow(org);hold on;plot(A1);
title('Displaying ellipses whose sizes are in the range of nuclie');
figure;imshow(dup);
title('Detected nuclei');