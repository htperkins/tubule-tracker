function OpenImage(hObject, eventdata)
FA = guidata(hObject);

%Open dialog for image selection
[fileName, filePath] = uigetfile({'*.*', 'NanoScope File (*.*)'; ...
    '*.flt', 'FLT image file (*.flt)'; ...
    '*.tif; *.tiff', 'Image file (*.tif, *.tiff)'});
if isequal(fileName, 0); return; end % Cancel button pressed

% Read image data according to its extension
switch utility.getFileExtension(fileName)
    case {'tif', 'tiff'} % *.tif or *.tiff
        % Read an image and store it in memory
        im = int16(imread(fullfile(filePath, fileName)));
        if size(im, 3) == 3 % In case of 3 channels (rgb), convert to grayscale
            im = int16(rgb2gray(im));
        elseif size(im, 3) == 4 % In case of RGBA, convert to grayscale assuming white background
            alpha = double(im(:,:,4))./255;
            im(:,:,4) = [];
            
            im(:,:,1) = alpha.*double(im(:,:,1)) + (1-alpha).*255;
            im(:,:,2) = alpha.*double(im(:,:,2)) + (1-alpha).*255;
            im(:,:,3) = alpha.*double(im(:,:,3)) + (1-alpha).*255;
            
            im = int16(rgb2gray(im));
        end
        
        % Information about image with default values
        [sizeY, sizeX] = size(im);
        sizeX_nm = sizeX;
        sizeY_nm = sizeY;
        scaleXY = 1;
        scaleZ = 1;
        
    case 'flt' % FLT file
        [im, sizeX, sizeY, sizeX_nm, sizeY_nm, scaleXY, scaleZ] = ...
            utility.readFltImage(filePath, fileName);
        
    otherwise % NanoScope
        [im, sizeX, sizeY, sizeX_nm, sizeY_nm, scaleXY, scaleZ] = ...
            utility.readNanoScopeImage(filePath, fileName);
end

% Check the image reading process
if isempty(im); return; end

% Save image information
FA.name = fileName;
FA.path = filePath;
FA.im = im;
FA.sizeX = sizeX;
FA.sizeY = sizeY;
FA.sizeX_nm = sizeX_nm;
FA.sizeY_nm = sizeY_nm;
FA.scaleXY = scaleXY;
FA.scaleZ = scaleZ;

% Calculate suggested proper step for tracking algorithm
%Removed these lines as they just seem to always set the step to 1
% FA.step_nm = utility.round2n(FA.scaleXY);
% FA.step = FA.step_nm/FA.scaleXY;
FA.step_nm = FA.step;

% Show image
set(gcf, 'Name', ['FiberApp - ' fullfile(filePath, fileName)]);
FA.updateImage();

FA.checkAccordance();

% Change a current folder
cd(filePath);

% Put main window in a focus
figure(gcf);

% FiberApp tutorial
switch utility.getFileExtension(fileName)
    case {'tif', 'tiff'} % *.tif or *.tiff
        FA.tutorial('open_tif_image');
        
    otherwise
        FA.tutorial('open_afm_image');
end

