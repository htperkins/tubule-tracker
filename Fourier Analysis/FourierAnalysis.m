%Function by Hannah Perkins 
%Runs all Fourier analysis scripts for a single video

function FourierAnalysis(file,structPath,pixelscale,exposureTime)

%Set up Fourier struct for the current video
[Fourier] = SetUpFourier(file,structPath);

%Analyse the most recent fibre. Change the number if you want to analyse a
%different fibre
fibreNum = size(Fourier,2);
%Find the backbone of the tubule, suppress spurious length changes and find
%the variance and skewness along the backbone
[Fourier] = BackBonePDF(Fourier,structPath,fibreNum);

%Analyse the fibre using Fourier decomposition
AnalysisFn(fibreNum,pixelscale.*Fourier(fibreNum).xCoords_pix,...
    pixelscale.*Fourier(fibreNum).yCoords_pix,exposureTime,structPath);