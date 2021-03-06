%% Metadata of main.m
% Choong Jin Ng
% 301226977
% jinn@sfu.ca
clear all;
close all;

%% Initialisation of images
filenames = {'image1.tif','image2.tif','image3.tif', ...
    'image4.tif','image5.tif','image6.tif','image7.tif','image8.tif', ...
    'image9.tif','image10.tif','image11.tif','image12.tif'};
sizeImages = size(filenames,2);
images{sizeImages} = 0;
sizeY = 600; sizeX = 600; % Since the image filesize is given....

for ii=1:sizeImages
    images{ii} = readImg(['Images/' filenames{ii}]);
end

%% Initialisation of filters
filter_laplacian = fspecial('log');
filter_average = fspecial('average');

%% Creation of diseased images
% for ii=1:1
%     noisyImg = mat2gray(images{1});
%     for xx=100:300
%         for yy=100:300
%             factor = round(rand());
%             noisyImg(yy,xx) = factor*noisyImg(yy,xx);
%         end
%     end
%     writeImage(noisyImg,'image6.tif','Images');
% end
% 
% for ii=1:1
%     noisyImg = mat2gray(images{1});
%     for xx=1:sizeX
%         for yy=1:sizeY
%             factor = round(rand());
%             noisyImg(yy,xx) = factor*noisyImg(yy,xx);
%         end
%     end
%     writeImage(noisyImg,'image7.tif','Images');
% end
% 
% for ii=1:1
%     noisyImg = mat2gray(images{1});
%     for xx=100:300
%         for yy=100:300
%             noisyImg(yy,xx) = 0;
%         end
%     end
%     writeImage(noisyImg,'image8.tif','Images');
% end
% writeImage(medfilt2(images{1}),'image9.tif','Images');
% writeImage(imgaussfilt(images{1}),'image10.tif','Images');
% writeImage(imfilter(images{1},filter_laplacian),'image11.tif','Images');
% writeImage(imfilter(images{1},filter_average),'image12.tif','Images');

%% Initalisation of result variables
photo_count{sizeImages} = 0;
map{sizeImages} = 0;
temp_img_c{sizeImages} = 0;

%% Initialisation of Masks
mask0 = [0 0 0;
    0 1 0;
    0 0 0];
mask1 = [1 1 1;
    0 3 0;
    1 1 1];
mask2 = [4 0 4;
    4 20 4;
    4 0 4];

%% Processing
tic;
for ii=1:sizeImages
    [~,filename] = fileparts(filenames{ii});
    [photo_count{ii},map{ii},temp_img_c{ii}] = ...
        receptorCounter(images{ii},mask2,filename,'all');
    close all;
end
toc
