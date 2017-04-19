%% Metadata of main.m
% Choong Jin Ng
% 301226977
% jinn@sfu.ca
clear all;
close all;

%% Initialisation of images
filenames = {'image1.tif','image2.tif','image3.tif','image4.tif','image5.tif'};
sizeImages = size(filenames,2);
images{sizeImages} = 0;
sizeY = 600; sizeX = 600; % Since the image filesize is given....

for ii=1:sizeImages
    images{ii} = readImg(['Images/' filenames{ii}]);
end

%% Initalisation of result variables
photo_count{sizeImages} = 0;
map{sizeImages} = 0;
temp_img_c{sizeImages} = 0;

%% Initialisation of Masks
mask1 = [0 0 0;
    0 1 0;
    0 0 0];

%% Processing
tic;
for ii=1:sizeImages
    [~,filename] = fileparts(filenames{ii});
    [photo_count{ii},map{ii},temp_img_c{ii}] = ...
        receptorCounter(images{ii},mask1,filename,'all');
    close all;
end
toc