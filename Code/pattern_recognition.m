clear all;


% TRAINING 


% reading individual binary cells from folder in which the images are saved

srcFiles = dir('H:\MATLAB\proj\*.png');  


% finding total boundary (by extracting boundary of each individual cell)

bound = zeros(1024);

for  i = 1   : length(srcFiles)
    filename = strcat('H:\MATLAB\proj\',srcFiles(i).name);
    A = imread(filename);
    B = bwboundaries(A);                    % index of boundary
    C = B{1,1}; 
    [m,n] = size(C);
    for(i=1:m)
        bound(C(i,1),C(i,2)) = 1;           % total boundary
    end
end

figure;imshow(bound);
title('Total boundary (Training)');


% finding outer boundary alone

fill = imfill(bound,'holes');               
interior = fill;
figure;imshow(interior);
% title('Inner pixels of the outer boundary');      
E = bwboundaries(fill);
outb_train = zeros(1024);
[m,n]=size(E);

for(k=1:m)
    F = E{k,1}; 
    [m1,n1] = size(F);
    for(i=1:m1)
        outb_train(F(i,1),F(i,2)) = 1;      % outer boundary
    end 
end

% figure;imshow(outb_train);
% title('Outer boundary (Training)');


% finding inner boundary alone

inb_train = bound-outb_train;
% figure;imshow(inb_train);
% title('Inner boundary (Training)');


% finding outer boundary of EDF image

original = imread('frame011.png');
[m_org,n_org] = size(original);
figure;imshow(original);
title('EDF image');

% nucleus

nucleus = imread('frame011_NUGT.png');
% figure;imshow(nucleus);
% title('Nuclei of all cells');


cutoff = graythresh(nucleus);
thresholded = im2bw(nucleus,cutoff);
nucleus = thresholded;
% figure;imshow(nucleus);
% title('Thresholded image of nuclei');


% computing the features of the inner pixels

dbl_org = double(original);
k = 1;
F = [];

for(i=2:m_org-1)  
    for(j=2:n_org-1)
        if(interior(i,j)==1)            %inner region detected
                
                sum = 0.0;
                orig_inv = 1.0/dbl_org(i,j);
                rel_err = [];
                kk = 1;
                
                for(ii=i-1:i+1)
                    for(jj=j-1:j+1)
                        if(~(i==ii&&j==jj))
                            % finding relative error of 8 neighbours around a pixel
                            rel_err(kk) =  abs(dbl_org(i,j)-dbl_org(ii,jj));
                            sum = sum+rel_err(kk);
                            kk = kk+1;
                        end
                    end
                end
                
                    % computing 4 features (gradients)
                    F(1,k) = abs(rel_err(6)-rel_err(3))*orig_inv;
                    F(2,k) = abs(rel_err(7)-rel_err(2))*orig_inv;
                    F(3,k) = abs(rel_err(1)-rel_err(8))*orig_inv;
                    F(4,k) = abs(rel_err(4)-rel_err(5))*orig_inv;
                    
                % assigning labels
                
                if(nucleus(i,j)==1)
                    F(5,k) = 0;             % nucleus label = 0 
                else if(inb_train(i,j)==1)  % inner boundarey pixel label = 1
                        F(5,k) = 1;
                    else 
                        F(5,k) = 2;         % other pixels label = 2
                    end 
                end
                k = k+1;
                
        end   
    end
end 
    

% TESTING


% finding outer boundary of EDF image (testing)
original = imread('frame011.png');

cutoff = 225/255;
thresholded = im2bw(original,cutoff);       % threshold to get a binary image
outb_id = bwboundaries(thresholded);
outb_test = zeros(m_org,n_org);
[m,n]=size(outb_id);

for(k=1:m)
    C = outb_id{k,1}; 
    [m1,n1] = size(C);
    if(m1>170)
        for(i=1:m1)
            outb_test(C(i,1),C(i,2)) = 1;       % outer boundary
        end
    end
end

figure;imshow(outb_test);
title('Outer boundary of EDF image(testing)');

interior_test1 = imfill(outb_test,'holes');
interior_test2 = imfill(outb_test,8);
interior_test = interior_test2 + imcomplement(interior_test1);
% figure;imshow(interior_test);
% title('Inner pixels for testing');

% computing features of inner pixels in EDF image

inp = [F(1,:); F(2,:); F(3,:); F(4,:)];
dbl_org = double(original);
k = 1;
tst = [];

for(i=2:m_org-1)  
    for(j=2:n_org-1)
       if(interior_test(i,j)==1)  
           
                sum = 0.0;
                orig_inv = 1.0/dbl_org(i,j);
                rel_err = [];
                kk = 1;
                
                for(ii=i-1:i+1)
                    for(jj=j-1:j+1)
                        if(~(i==ii&&j==jj))
                            rel_err(kk) =  abs(dbl_org(i,j)-dbl_org(ii,jj));
                            sum = sum+rel_err(kk);
                            kk = kk+1;
                        end
                    end
                end
                
                    tst(1,k) = abs(rel_err(6)-rel_err(3))*orig_inv;
                    tst(2,k) = abs(rel_err(7)-rel_err(2))*orig_inv;
                    tst(3,k) = abs(rel_err(1)-rel_err(8))*orig_inv;
                    tst(4,k) = abs(rel_err(4)-rel_err(5))*orig_inv;

                k = k+1;
       end
    end
end 

% k nearest neighbour classifier (5NN classifier is used here)

near = 5;
[n,dst] = knnsearch(inp',tst','k',near);


% final sengmentation of cell

dup3 = original;    
k = 1;
for(i=2:m_org-1)  
    for(j=2:n_org-1)
        if(interior_test(i,j)==1)  
            
            bnd = 0;
            for(c=1:near)
                if(F(5,n(k,c))==1)      % check label
                    bnd = bnd + 1;
                end
            end
            
             if(bnd>0||outb_test(i,j)==1)
                dup3(i,j) = 0;
            end
            k = k+1;    
            
        end
    end
end  

figure;imshow(dup3);
title('Final segmented cell image');


% Nuclei detection

dup3 = original;    
k = 1;
for(i=2:m_org-1)  
    for(j=2:n_org-1)
        if(interior_test(i,j)==1)  
            
            bnd = 0;
            for(c=1:near)
                if(F(5,n(k,c))==0)      % check label
                    bnd = bnd + 1;
                end
            end
            
             if(bnd>0||outb_test(i,j)==1)
                dup3(i,j) = 0;
            end
            k = k+1;    
            
        end
    end
end  

figure;imshow(dup3);
title('Detected nuclei image');