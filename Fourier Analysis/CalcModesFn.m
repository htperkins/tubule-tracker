%Script by Hannah Perkins 1/18
%Uses NumericalFModes to calculate modes for every image from FiberApp
%Run ImageDataToStruct first

function modefit = CalcModesFn(xMat,yMat)
n=10;   %Number of Fourier modes to be fitted

for img = 1:size(xMat,2)
    [an,L,s,tangent,Theta,smid] = NumericalFModes(xMat(:,img),yMat(:,img),n);
    modefit(img).an = an;
    modefit(img).L = L;
    modefit(img).s = s;
    modefit(img).tangents = tangent;
    modefit(img).Theta = Theta';
    modefit(img).smid = smid;
    clear x y
end