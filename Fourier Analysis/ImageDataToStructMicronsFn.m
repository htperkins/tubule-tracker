% Function by Hannah Perkins 01/19, based on Script written by Henry Cox 01/2017
% Script exports data from the FiberApp ImageData file structure and
% performs post processing to determine persistence length, contour length,
% end to end distances etc 
% input pixel size in microns and number of images

function [Images] = ImageDataToStructMicronsFn(pixelsize,numberofimages,imageData)
% remove old Images structure and initiate property variables
clear Images

% loop through all Images
for i = 1:numberofimages
    
    % export main properties from FiberApp
    Images(i).name = imageData(1,i).name;
    Images(i).sizeX = imageData(1,i).sizeX;
    Images(i).sizeY = imageData(1,i).sizeY;
    Images(i).sizeX_um = imageData(1,i).sizeX_nm;
    Images(i).sizeY_um = imageData(1,i).sizeY_nm;
    Images(i).xy = imageData(1,i).xy;
    Images(i).z = imageData(1,i).z;
    Images(i).xy_um = imageData(1,i).xy_nm;
    Images(i).z_um = imageData(1,i).z_nm;
    Images(i).length_um = imageData(1,i).length_nm;
    Images(i).height_um = imageData(1,i).height_nm;
        
    % loop through each fiber
    for j = 1:size(Images(i).xy,2)
        
        % apply correction for pixel size
        Images(i).xy_um{j} = pixelsize.*Images(i).xy{j};
        
    end
    
    % apply pixel size corrections to other factors in structure
    Images(i).sizeX_um = pixelsize.*Images(i).sizeX;
    Images(i).sizeY_um = pixelsize.*Images(i).sizeY;
    Images(i).length_um = pixelsize.*Images(i).length_um;
    
       
end
clear Lp k xpts ypts i j sLp number