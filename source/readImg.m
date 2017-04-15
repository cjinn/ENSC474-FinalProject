%% readImg: Reads the Image and outputs a Greyscaled Image, ready for Image Processing
%
% INPUT:
% filename - Filename of the image. Does not assume it is grayscaled
%
% OUTPUT:
% new_img - Image ready for Image processing
% img_size - The Image size

function [new_img,img_size] = readImg(filename)
%% Reading from the file
temp_img = imread(filename);
temp_img = double(temp_img);
temp_img = mat2gray(temp_img);

%% If colour image, greyscale it
if (size(size(temp_img),2))
    temp_img = mean(temp_img,3);
    temp_img = mat2gray(temp_img);
end

%% Exporting image
new_img = temp_img;
img_size = size(new_img);

end

