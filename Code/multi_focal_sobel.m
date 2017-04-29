clear all;

original = imread('frame011.png');
figure;imshow(original);
title('EDF image');
[m,n] = size(original);
dup1 = original;
dup2 = original;


%obtaining boundary from EDF image

thresh = 0.025;                     %threshold
A = edge(original,'sobel',thresh);
B = bwareaopen(A,10);
figure;imshow(imcomplement(B));
title('Boundary of cell from EDF image');


%overlaying the boundary(obtained from EDF image) to get segmented cell image

for(i=1:m)
    for(j=1:n)
        if(B(i,j)==1)
            dup1(i,j)=0;
        end
    end
end

figure;imshow(dup1);
title('Segmeneted cell image from EDf image');


%obtaining boundary from multi-focal images

srcFiles1 = dir('H:\MATLAB\frame011_stack\*.png');
C1 = zeros(m,n);
 for    i = 1  : length(srcFiles1)
    filename = strcat('H:\MATLAB\frame011_stack\',srcFiles1(i).name);
    A1 = imread(filename);
    B1 = edge(A1,'sobel',thresh);
    E1 = bwareaopen(B1,10);
    
    for(i=1:m)
        for(j=1:n)
            if(E1(i,j)==1)
                C1(i,j) = 1;
            end
        end
    end
    
 end

final = bwareaopen(C1,30);
figure;imshow(imcomplement(final));title('Segmeneted cell image from multi-focal images');


% overlaying the boundary(obtained from multi-focal images) to get segmented cell image

for(i=1:1024)
    for(j=1:1024)
        if(final(i,j)==1)
            dup2(i,j)=0;
        end
    end
end
figure;imshow(dup2); title('Segmeneted cell image from multi-focal images');
