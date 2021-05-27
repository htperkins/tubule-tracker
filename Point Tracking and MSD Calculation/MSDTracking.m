%Script by Hannah Perkins 
%1D ER tubule tracking code. Based on work by Pantelis Georgiades (doi:10.1038/s41598-017-16570-4).

%Set up video details etc.
close all; clear;
profile = [];
filename = 'ExampleTubuleMSD';
framerate = 1/(30*10^(-3));    %Number of frames per second, or 1/exposure time
pixelscale = 0.104;        %Size of one pixel in microns
coordDef = 'click';      %'type' if re-analysing from previous MSD or 'click' to use mouse
datanum = 57;       %Use for 'type' only - this is the row of the struct to re-analyse
saveMSDpath = 'C:\...\MSDStruct.mat'; %Fill in the path where you would like the data to be saved to

%Set up model as a Gaussian with an offset
model = @(b,x)((b(1).*gaussmf(x,[b(2) b(3)]))+b(4));
%Use iteratively reweighted least squares fitting, with a Cauchy error
%model. This expects more extreme outliers in the profile and can fit
%the rest of the data while ignoring outliers.
opts = statset('nlinfit');
opts.MaxIter = 10000;
opts.RobustWgtFun = 'cauchy';

%Read in the first image and show it
I = imread([filename '.tif'],1); I = imadjust(I);
imshow(I,'InitialMagnification','fit');
%If re-analysing previous data, plot the line. If data is new, get the user
%to define whe line across which to track the tubule
if strcmp(coordDef,'type')
    load(saveMSDpath);
    xline = [MSDData(datanum).xLimits];
    yline = [MSDData(datanum).yLimits];
    %To define the example tubule manually, the following two lines can be
    %uncommented. The 3 lines above must then be commented out
%      xline = [5.448979591836735;13.489795918367346];
%      yline = [12.724489795918366;4.520408163265305];
    hold on;
    plot(xline,yline);
    close all; clear I;
elseif strcmp(coordDef,'click')
    [xline,yline] = getpts; 
    close all; clear I;
end

%Fit a first order polynomial to the two points defining the profile.
p = polyfit([xline(1,1) xline(2,1)],...
    [yline(1,1) yline(2,1)],1);

%Loop through all frames of the video. Setting high frame value to 2000,
%but trying to open as many frames as possible. If the index becomes larger
%than the number of frames, exit the loop
for ii = 1:2000
    try
        frame = imread([filename '.tif'],ii);
    catch
        break;
    end
    %Get the intensity profile across the line. Have assigned bicubic
    %method of interpolation to use surrounding points in intensity
    %estimation, not just the pixel the line passes through
    [xpix, ypix, preintensity] =...
        improfile(frame,xline,yline,'bicubic');
    %If the points were chosen too close to the edge of a frame, improfile
    %will return NaN values at the edges and kriging will not work
    if isnan(preintensity)
        error(['Chosen points are too close to the edge of the frame.' ...
            'Re-run the code and pick points further from the frame edges.']);
    end
    
    %Find the distance along the line, instead of just the co-ordinates.
    %Set the first value to zero so that the length of r is the same as
    %xpix
    prer(1) = 0;
    prer(2:size(xpix,1),1) = cumsum(sqrt(diff(xpix).^2+diff(ypix).^2));
    
    %Interpolate the intensity data using kriging. This ensures that
    %measured values aren't changed, but interpolates between them using
    %maximum likelihood estimation
    warning('off','MATLAB:nearlySingularMatrix')
    [r,intensity] = doKrig(prer,preintensity,100);
    
    %Find the maximum intensity and therefore the guess of the midpoint.
    %Ignore the first and last points
    [maxInt,ind] = max(intensity(2:end-1));
    %Correct for skipping the first point
    ind = ind+1;
    %Test the interpolated signal for problems. If there are the same ...
    %or a greater number of turning points than input points in
    % the data, the krig has failed. In this case,
    %use improfile but resampled 100 times. Also remove the
    % edges.
    %If the krig works, but the maximum is found right at the edge, remove
    %the edges.
    zeroCrossing(ii) = size(find(diff(diff(intensity)>=0)),1);
    %Plotting sections are commented
    if zeroCrossing(ii)>=size(prer,1)
%         figure;
%         plot(r,intensity)
%         legend(['zero crossing = ' num2str(zeroCrossing(ii))])
%         krigFit = profileFit(r,intensity,model,opts);
%         hold on; plot(r,model(krigFit,r))
        clear r intensity
        [xpix, ypix, intensity] =...
        improfile(frame,xline,yline,100,'bicubic');
        r(1) = 0;
        r(2:size(xpix,1),1) = cumsum(sqrt(diff(xpix).^2+diff(ypix).^2));
%         hold on;plot(r,intensity)
%         fullBicubFit = profileFit(r,intensity,model,opts);
%         hold on; plot(r,model(fullBicubFit,r))
        %Invert the signal and find the first and last minima (maxima in
        %the inverted function). Use these indices (B) as the indices
        %between which to fit the data
        inv = max(intensity)-intensity;
        [~,B] = findpeaks(inv);
        %If only one minimum is found, use the start/end of the signal
        if length(B)<2
            if B<=0.5*size(r,1)
                B(2) = size(r,1);
            elseif B>0.5*size(r,1)
                B = [1;B];
            elseif isempty(B)
                B = [1;size(r,1)];
            end
        %If both values found are below or above the previous midpoint,
        %re-adjust the values so that the previous midpoint is not excluded
        %from the profile
        elseif ii > 1 && r(B(2)) < midpoint(ii-1)
            B = [B(2);size(r,1)];
        elseif ii > 1 && r(B(1)) > midpoint(ii-1)
            B = [1;B(1)];
        end
        %Remove the start and end that are before and after the minima
        intensity = intensity(B(1):B(end));
        r = r(B(1):B(end));
%         eroBicubFit = profileFit(r,intensity,model,opts);
%         hold on; plot(r,intensity);plot(r,model(eroBicubFit,r))
%         legend('Krig','Krig Fit','Full Bicub','Full Bicubic Fit','Eroded Bicubic','Eroded Bicubic Fit');    
    elseif ind == 2 || ind == size(intensity,1)-1
        %If this error has occurred because of NaNs in the signal, don't
        %use krig but rather the bicubic method
        if isnan(intensity)
            intensity = improfile(frame,xline,yline,100,'bicubic');
        end
        %Invert the signal and find the first and last minima (maxima in
        %the inverted function). Use these indices (B) as the indices
        %between which to fit the data
        inv = max(intensity)-intensity;
        [~,B] = findpeaks(inv);
        %If only one minimum is found, use the start/end of the signal
        if length(B)<2
            if B<0.5*size(r,1)
                B(2) = size(r,1);
            elseif B>0.5*size(r,1)
                B = [1;B];
            elseif isempty(B)
                B = [1;size(r,1)];
            end
             %If both values found are below or above the previous midpoint,
        %re-adjust the values so that the previous midpoint is not excluded
        %from the profile
        elseif r(B(2)) < midpoint(ii-1)
            B = [B(2);size(r,1)];
        elseif r(B(1)) > midpoint(ii-1)
            B = [1;B(1)];
        end
        %Remove the start and end that are before and after the minima
        intensity = intensity(B(1):B(end));
        r = r(B(1):B(end));  
    end
    %%
    %Calculate the SNR for the specific frame and return an error if it is
    %too low. This threshold was found by simulating the data (See
    %supplementary)
    SNR(ii) = CheckSNR(r,intensity);
    if SNR(ii) < 3.6*10^(4)
        disp(['SNR = ' num2str(SNR(ii))]);
        %Check where the error occurs. If it is in the first or last 10% of
        %the data ONLY, then keep the track outside of the problem region
        error(['SNR below threshold for frame ' num2str(ii)]);
    end
    %Fitting parameter calculations and fitting
    [xo(:,ii), profFit(ii,:)] = profileFit(r,intensity,model,opts);
    
    %%
    %FIND POSITION 
    %x-position is the midpoint of the gaussian in the fit
    %y-position is the position along the straight line between the points
    %at which the midpoint of the gaussian occurs
    midpoint(ii) = profFit(ii,3);

end

%Plot the midpoint over time
figure;plot(midpoint);
xlabel('Frame');ylabel('Tubule Centre (pix)');
%To check the tracking, can produce a video with the overlaid tracked
%points - THIS WILL MAKE THE CODE MUCH SLOWER!  
%TrackingOverlay(filename,xline,yline,midpoint);

%Calculate the MSD
[MSD, Alpha, D, plateau, intercept, plateauRange,endNoiseGuess] =  ...
        MSD_single(midpoint,framerate,pixelscale);


%%
%SAVING
if exist(saveMSDpath,'file') == 0
    
    MSDData.Frames = [1;size(midpoint,2)];
    MSDData.xLimits = xline;
    MSDData.yLimits = yline;
    MSDData.Track = midpoint;
    MSDData.File = filename;
    MSDData.Framerate = framerate;
    MSDData.OriginalMSD = MSD;
    MSDData.MSDIntercept = intercept;
    MSDData.Alpha = Alpha;
    MSDData.DiffCoeff = D;
    MSDData.Plateau = plateau;
    MSDData.PlateauRange = plateauRange;
    MSDData.NoiseStarts = endNoiseGuess;
    save(saveMSDpath,'MSDData')
else
    load(saveMSDpath)
    ii = size(MSDData,2)+1;
    MSDData(ii).File = filename;
    MSDData(ii).Framerate = framerate;
    MSDData(ii).Frames = [1;size(midpoint,2)];
    MSDData(ii).xLimits = xline;
    MSDData(ii).yLimits = yline;
    MSDData(ii).Track = midpoint;
    MSDData(ii).OriginalMSD = MSD;
    MSDData(ii).MSDIntercept = intercept;
    MSDData(ii).Alpha = Alpha;
    MSDData(ii).DiffCoeff = D;
    MSDData(ii).Plateau = plateau;
    MSDData(ii).PlateauRange = plateauRange;
    MSDData(ii).NoiseStarts = endNoiseGuess;
    save(saveMSDpath,'MSDData')
end



