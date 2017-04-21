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

imwrite(temp_img, img_filename);
end
