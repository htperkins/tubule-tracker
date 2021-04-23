%Function by Hannah Perkins 06/18
%Calculates MSD from a track
%Gives MSD in microns^2

function [MSD, Alpha, D, plateau, intercept, plateauRange,endNoiseGuess] = ...
    MSD_single(track,framerate,pixscale)

track2 = track*pixscale;
MSD = zeros(1,size(track,2)-1);

%Check that the data is in vector form
if size(track2,2) > size(track2,1)
    track2 = track2';
end
%Calculate MSD
for ii = 1:size(track2,1)-1
    MSD(ii) =(mean((track2(1+ii:end,:)-track2(1:end-ii,:)).^2));
end

%Fit first 5 points to find the intercept
lagTime = (1:size(MSD,2))/framerate;
%Fit a straight line to the first 5 points of the MSD
floorFit = polyfit(lagTime(1:5),MSD(1:5),1);
intercept = floorFit(1,2);


%Find the plateau
%First find the 10-point estimated gradient
for jj=1:size(MSD,2)-10;
    grad10(jj) = log(MSD(jj+10)/MSD(jj))/log(lagTime(jj+10)/lagTime(jj));
end
%Use the gradient multiplied by the gradient shifted by one to find where
%the gradient crosses zero
zerotest = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0);
%Look for these values in the first 15% of the data
zerovals = zerotest(grad10(1:floor(0.15*size(grad10,2))));
%If zerovals isn't empty, use the first value as the start of the plateau
if ~isempty(zerovals)
    plateauRange = [zerovals(1) zerovals(end)];
    plateau = MSD(zerovals(1));
else
    plateauRange = NaN;
    plateau = NaN;
end

%Fit MSD = D*tau^(alpha)
model = @(b,x)(b(1)*x.^(b(2)));
%If the plateau doesn't exist, or has been detected very early 
%(less than 20 points in), just fit to the first 15% of the data
threshold = floor(0.15*size(MSD,2));
if isnan(plateau) || plateauRange(1)<20
    MSDFit = nlinfit(lagTime(1:threshold),MSD(1:threshold),model,[1E-3 0.5]);
    Alpha = MSDFit(2);
    D = MSDFit(1);
    else
    MSDFit = nlinfit(lagTime(1:plateauRange(1)),MSD(1:plateauRange(1)),model,[1E-3 0.5]);
    Alpha = MSDFit(2);
    D = MSDFit(1);
end

%Plot ln of corrected MSD with fit
figure;
loglog((lagTime),(MSD),'DisplayName','Original MSD')
hold on;
loglog((lagTime),(model(MSDFit,lagTime)),'DisplayName','Original MSD Fit')
if ~isnan(plateauRange)
    loglog(lagTime(plateauRange(1):plateauRange(2)),MSD(plateauRange(1):plateauRange(2)))
end
xlabel('Lagtime (s)');ylabel('MSD (\mum^{2})');

%Find large changes in values and therefore the start of the noisy section
lastVal = floor(size(MSD,2)*0.75);
endNoiseGuess = (1/framerate)*findchangepts(diff(MSD(1:lastVal))/0.0001,'Statistic','linear');

