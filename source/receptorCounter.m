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
%% Initialisation of Image Variables
[sizeY,sizeX] = size(img);

%% Initialisation of Mask Variables
size_mask = size(mask);

%% Initialisation of Output variables
map = zeros(size_mask);
photoCount = 0;

%% Initialisation of Temporary variables
temp_img = img;

%% Initialisation of Parameter Variables
% Modify this if you want to adjust how the function adjust
k_factor = 16;
iterations = 100;

%% Initialisation of Debugging variables
f_version = 'v0.01.003'; % Version of files

%% Initialisation for Debugging
if (strcmp(debug,'none') && ...
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
temp_img_c{k_factor} = 0;

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

%% Counting the number of photoreceptors
photoCount = sum(sum(temp_img));

%% Analysing its FFT of the image
img_fft = getFFTImg(img);

if (strcmp(debug,'all') || strcmp(debug,'fft'))
    if (exist(['Debug/' f_version '/FFT/' filename],'dir') ~= 7)
        mkdir(['Debug/' f_version '/FFT/' filename]);
    end
    
    fig = figure('Name',['FFT of ' filename]);
    mesh(real(img_fft));
    title(['FFT of ' filename]);
    saveas(fig, ['Debug/' f_version '/FFT/' filename '/original_fft'], 'png');
end

%% Output
if (exist(['Results/' filename],'dir') ~= 7)
    mkdir(['Results/' filename]);
end

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

%% getFFTImg: Gets the image in the frequency domain
%
% INPUT:
% img - Image
%
% OUTPUT:
% img_fft - Image in the Frequency Domain. It has been logged.
function [img_fft] = getFFTImg(img)
img_fft = fft2(img);
img_fft = fftshift(img_fft);
notzeros = (img_fft ~= 0);
img_fft(notzeros) = log10(abs(img_fft(notzeros)));
end
