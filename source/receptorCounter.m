%% receptorCounter: Counts the number of photo receptors of the eye and returns a sample map of it
% v0.01.001
%
% INPUT:
% img - A greyscaled Image.
% mask - A user-provided mask
% filename - Filename of the image. Will save results/debug info using this
% filename.
% debug - Variable that helps to debug.
%   'all' - All parts are used to debug.
%   'segmentation' - Only segmentation is debugged.
%   '' - 
%
% OUTPUT:
% photoCount - The total number of photo receptors in the eye approximated.
% map - Quantity map of the photoreceptors. Same size as the mask
%
function [photoCount,map,temp_img_c] = receptorCounter(img,mask,filename,debug)
%% Initialisation of Temporary variables
temp_img = img;

%% Initialisation of Parameter Variables
% Modify this if you want to adjust how the function adjust
k_factor = 16;
iterations = 100;

%% Initialisation of Debugging variables
f_version = 'v0.02.002'; % Version of files

%% Initialisation for Debugging
if (~strcmp(debug,'none') && ...
        exist(['Debug/' f_version],'dir') ~= 7)
    mkdir(['Debug/' f_version]);
end

if ((strcmp(debug,'all') || strcmp(debug,'segmentation')) && ...
        exist(['Debug/' f_version '/Segmentation/' filename],'dir') ~= 7)
    temp_img_initial_c{k_factor} = 0;
    mkdir(['Debug/' f_version '/Segmentation/' filename]);
end

%% Segmenting the Image
temp_img = temp_img(:);
[~,initial_C] = intensitySegment(img,k_factor);
index = kmeans(temp_img,k_factor,'Start',initial_C);
temp_img = reshape(index,size(img));
temp_img_c{k_factor + 1} = 0;

for ii=1:k_factor
    temp_img_c{ii} = (temp_img == ii);
    temp_img_c{ii} = mat2gray(temp_img_c{ii});
    
    %% Debugging Segmentation
    if (strcmp(debug,'all') || strcmp(debug,'segmentation'))
        %% Initial Seed via Intensity Segmentation
        temp_img_initial_c{ii} = (temp_img == ii);
        temp_img_initial_c{ii} = mat2gray(temp_img_initial_c{ii});
        
        fig = figure('Name', [filename ' Initial Seed with k=' num2str(k_factor)]);
        subplot(1,2,1);
        imshow(im2uint8(img));
        title('Original Image');
        subplot(1,2,2);
        imshow(im2uint8(temp_img_c{ii}));
        title(['Initial Segmented Image with k=' num2str(k_factor) ...
            ', Cluster ' num2str(ii)]);
        saveas(fig, ...
            ['Debug/' f_version '/Segmentation/' filename '/segment_k_factor_initial_' ... 
            num2str(k_factor) '_cluster_' num2str(ii)], 'png');
        
        %% k-means Clustering
        fig = figure('Name',[filename ' Segmentation with k=' num2str(k_factor)]);
        subplot(1,2,1);
        imshow(im2uint8(img));
        title('Original Image');
        subplot(1,2,2);
        imshow(im2uint8(temp_img_c{ii}));
        title(['Segmented Image with k=' num2str(k_factor) ...
            ', Cluster ' num2str(ii)]);
        saveas(fig, ...
            ['Debug/' f_version '/Segmentation/' filename '/segment_k_factor_' ... 
            num2str(k_factor) '_cluster_' num2str(ii)], 'png');
    end
end

%% Isolating to get the photoreceptors
unwanted_cluster = temp_img_c{1} + temp_img_c{2} + temp_img_c{3};
temp_img = activecontour(img,unwanted_cluster,iterations);
temp_img = imcomplement(temp_img); % Inverse colour it

%% Debugging isolation
if (strcmp(debug,'all') || strcmp(debug,'segmentation'))
    fig = figure('Name', [filename ...
        ' Final Result of Segmentation']);
    subplot(1,3,1);
    imshow(im2uint8(img));
    title('Original Image');
    subplot(1,3,2);
    imshow(im2uint8(imcomplement(unwanted_cluster)));
    title('Before Contour');
    subplot(1,3,3);
    imshow(im2uint8(temp_img));
    title('After Contour');
    saveas(fig, ...
        ['Debug/' f_version '/Segmentation/' filename '/segment_final_result_iterations' ... 
        num2str(iterations) '_k_factor_' num2str(k_factor)], 'png');
end

%% Applying Mask
masked_img = mask_image(temp_img,mask);

if (strcmp(debug,'all') || strcmp(debug,'mask'))
    if (~exist(['Debug/' f_version '/Mask/' filename],'dir'))
        mkdir(['Debug/' f_version '/Mask/' filename]);
    end
    
    fig = figure('Name', [filename ' Masked Image']);
    subplot(1,2,1);
    imshow(im2uint8(temp_img));
    title('Before Masking');
    subplot(1,2,2);
    imshow(im2uint8(masked_img));
    title('After Masking');
    saveas(fig, ...
        ['Debug/' f_version '/Mask/' filename '/' filename '_masked'], 'png');
end

temp_img_c{k_factor + 1} = masked_img;

%% Counting the number of photoreceptors
photoCount = round(sum(sum(masked_img)));

%% Mapping density
density_img = label2rgb(masked_img,'colorcube');
map = imcomplement(density_img);

if (strcmp(debug,'all') || strcmp(debug,'map'))
    if (~exist(['Debug/' f_version '/Map/' filename],'dir'))
        mkdir(['Debug/' f_version '/Map/' filename]);
    end
    
    fig = figure('Name', [filename ' Mapped Image']);
    subplot(2,2,1);
    imshow(im2uint8(img));
    title('Original Image');
    subplot(2,2,2);
    imshow(im2uint8(masked_img));
    title('Masked & Cleaned');
    subplot(2,2,3);
    imshow(im2uint8(density_img));
    title('Original Colour');
    subplot(2,2,4);
    imshow(im2uint8(map));
    title('Map (Final Result)');
    saveas(fig, ...
        ['Debug/' f_version '/Map/' filename ...
        '/' filename '_map'], 'png');   
end

%% Output
if (exist(['Results/' filename],'dir') ~= 7)
    mkdir(['Results/' filename]);
end

%% Saving results    
writeImage(map, [filename '_map'], ['Results/' filename]);

end

%% intensitySegment: Segments the image into regions based on image intensity
%
% INPUT:
% img - Image. Assumed to be greyscaled.
% k - Number of clusters. Assumed to be a positive integer greater than 1.
%
% OUPUT:
% index - Image matrix separated into different regions. Output as a 1-D
% matrix.
% C - Mean centroid
%
function [index,C] = intensitySegment(img,k)
%% Initialisation
temp_img = mat2gray(img);
[sizeY,sizeX] = size(temp_img);
index = zeros(sizeY,sizeX,k);

C(k,1) = 0;
boundary(k,2) = 1;

%% Error Checking
if (k < 2 || isinteger(k))
    return;
end

%% Regions
for ii=1:(k)
    %% Boundary locations
    if (ii == 1)
        boundary(ii,:) = [0,1/(k)]; % -1 because we want to include white values
    else
        prev_val = boundary(ii-1,2);
        boundary(ii,:) = [prev_val, prev_val + 1/(k)];
    end
end

%% Dividing into their respective regions
for ii=1:sizeY
    for jj=1:sizeX
        for kk=1:k
            val = temp_img(ii,jj);
            
            %% First, Last Region, and in-between (but not at the boundary)
            if ((kk == 1 && boundary(kk,1) <= val && val < boundary(kk,2)) || ...
                    (kk == k && boundary(kk,1) < val && val <= boundary(kk,2)) || ...
                    (boundary(kk,1) < val && val < boundary(kk,2)))
                index(ii,jj,kk) = 1;
            %% In-between
            elseif (kk ~= 1 && boundary(kk,1) == val)
                index(ii,jj,kk-1) = 0.5;
                index(ii,jj,kk) = 0.5;
            end
        end
    end
end

%% Calculating the mean
for kk=1:k
    C(kk,1) = sum(sum(img.*index(:,:,kk)))/sum(sum(index(:,:,kk)));
end

end

%% mask_image: 
% Masks the image using a provided kernel.
%
% INPUT:
% img - Image file
% kernel - Matrix to apply mask towards
%
% OUTPUT:
% new_img - New image after kernel has been applied to it
function [new_img] = mask_image(img,kernel)
%% Getting the sizes of the image and kernel
[row,col] = size(img);
[k_row, k_col] = size(kernel);

%% Error Checking
if (k_row < 1 || k_col < 1 || row < 1 || col < 1)
    new_img = img;
    return;
end

%% Applying the kernel
% 1x1 matrix
if (k_row == 1 && k_col == 1)
    new_img = kernel(1,1)*img;
% MxN matrix where M & N are both odd numbers
elseif (mod(k_row,2) == 1 && mod(k_col,2) == 1)
    new_img = kernel_process_all_odd(img,kernel);
% Reject where M & N are both not odd numbers
else
    new_img = img;
%     new_img = kernel_process_even(img,kernel);
end
end

%% kernel_process_all_odd:
% Applies the kernel to the image. Assumes the kernel size is all odd numbers
function [new_img] = kernel_process_all_odd(img,kernel)
%% Initialisation
[row,col] = size(img);
[k_row, k_col] = size(kernel);

k_row_mid = ceil(k_row/2);
k_col_mid = ceil(k_col/2);

new_img = zeros(row,col);

%% Error Checking
if (k_row < 1 || k_col < 1 || row < 1 || col < 1)
    new_img = img;
    return;
end

%% Processing
for ii=1:row
    for jj=1:col
        temp = 0;
        
        for xx=(-k_row_mid+1):(k_row_mid-1)
            new_ii = ii + xx;
            new_xx = xx + k_row_mid;
            for yy=(-k_col_mid+1):(k_col_mid-1)
                new_jj = jj + yy;
                new_yy = yy+k_col_mid;
                
                %% Only within image and kernel dimensions, and the kernel must have a non-zero value
                if (new_ii > 0 && new_jj > 0 && ...
                        new_ii <= row && new_jj <= col && ...
                        new_xx > 0 && new_yy > 0 && ...
                        new_xx <= k_row && new_yy <= k_col && ...
                        kernel(new_xx,new_yy) ~= 0)
                    temp = temp + kernel(new_xx,new_yy)*img(new_ii,new_jj);
                end
            end
        end
        
        %% Storing the new pixel value
        new_img(ii,jj) = temp;
    end
end
end

%% kernel_process_even:
% Applies the kernel to the image. Assumes the kernel size has at least one
% even number. More computational expensive.
%% WORK IN PROGRESS
% function [new_img] = kernel_process_even(img,kernel)
% %% Initialising sizes and median for image and kernel, and new_img
% [row,col] = size(img);
% [k_row, k_col] = size(kernel);
% k_row_mid = k_row/2;
% k_col_mid = k_col/2;
% depth = 4;
% 
% new_img = zeros(row,col);
% temp_img = zeros(row,col,depth);
% 
% %% Error Checking
% if (k_row < 1 || k_col < 1 || row < 1 || col < 1)
%     new_img = img;
%     return;
% end
% 
% %% Adjusting variables depending if row/column is an even/odd size
% % Odd Row
% if (mod(k_row,2) == 0)
%     k_row_mid = ceil(k_row_mid);
%     k_row_begin = -k_row_mid+1;
%     k_row_end = k_row_mid-1
%     depth = 2;
% % Even Row
% else
%     k_row_begin = -k_row_mid+1;
%     k_row_end = k_row_mid;
% end
% 
% % Odd Column
% if (mod(k_col,2) == 0)
%     k_col_mid = ceil(k_col_mid);
%     k_col_begin = -k_col_mid+1;
%     k_col_end = k_col_mid-1
%     depth = 2;
% % Even Column
% else
%     k_col_begin = -k_col_mid+1;
%     k_col_end = k_col_mid;
% end
% 
% %% Processing
% for ii=1:row
%     for jj=1:col
%         num_elements = 0;
%         temp = 0;
%         
%         for xx=k_row_begin:k_row_end
%             new_ii = ii + xx;
%             new_xx = xx + k_row_mid;
%             for yy=k_col_begin:k_col_end
%                 new_jj = jj + yy;
%                 new_yy = yy+k_col_mid;
%                 
%                 %% Only within image and kernel dimensions, and the kernel must have a non-zero value
%                 if (new_ii > 0 && new_jj > 0 && ...
%                         new_ii <= row && new_jj <= col && ...
%                         new_xx > 0 && new_yy > 0 && ...
%                         new_xx <= k_row && new_yy <= k_col && ...
%                         kernel(new_xx,new_yy) ~= 0)
%                     temp = temp + kernel(new_xx,new_yy)*img(new_ii,new_jj);
%                 end
%             end
%         end
%         
%         %% Storing the new pixel values
%         if (num_elements > 0 && temp >= 0)
%             % Stores them in depth to average them later
%             for dd=1:depth
%                 if (temp_img(ii,jj,dd) == 0)
%                     temp_img(ii,jj,dd) = temp;
%                 end
%             end
%         end
%     end
% end
% 
% %% Averaging the new values
% for ii=1:row
%     for jj=1:col
%         temp = 0;
%         dd = 0;
%         for kk=1:depth
%             if (temp_img(ii,jj,kk) ~= 0)
%                 temp = temp + temp_img(ii,jj,kk);
%                 dd = dd + 1;
%             end
%         end
%         
%         if (temp ~= 0 && dd ~= 0)
%             temp = temp/dd;
%         else
%             temp = 0;
%         end
%         
%         new_img(ii,jj) = temp;
%     end
% end
% end

%% writeImage: Writes the image to a specified location as a JPEG file
%
% INPUT:
% img - Image to be saved. Assumes need to convert back to Grayscale and to
% int8
% filename - Filename of the Image
% location - Specified location
function [] = writeImage(img,filename,location)
temp_img = img;
temp_img = mat2gray(temp_img);
temp_img = im2uint8(temp_img);

if (~isempty(location))
    img_filename = [location '/' filename];
else
    img_filename = filename;
end

imwrite(temp_img, [img_filename '.jpg']);
end
