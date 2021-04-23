%Script by Hannah Perkins 
%Fourier Mode Analysis set up for contours found using Contour Tracking
%Requires imageData from FiberApp, then sets up struct to save to 
%Variables:
%file is the results file from contour tracking, with extension eg.
%video1(1)Results.mat
%structPath is where the Fourier results struct is to be saved (or is
%already saved), including the file name eg. 'C:\Users\....\FourierData.mat'

function [Fourier] = SetUpFourier(file,structPath)

load(file);

%%
%Save to struct
if exist(structPath,'file') == 0
    Fourier(1).Video = imageData(1,1).name;
    Fourier(1).SourceFile = file;
    save(structPath,'Fourier');
else
    load(structPath)
    ii = size(Fourier,2)+1;
    Fourier(ii).Video = imageData(1,1).name;
    Fourier(ii).SourceFile = file;

    save(structPath,'Fourier');
end