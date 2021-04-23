%Script by Hannah Perkins 12/20
%Plots all required graphs if plot set to 1 for Fourier Mode Analysis from
%FiberApp (automated)
%Also saves all data to a struct called Fourier
%Requires imageData from FiberApp, then runs through complete workflow
%Exposure time is measured in seconds

function [Fourier] = AnalysisFn(tubNum,x,y,exposureTime,structPath)

isplot = 1;   %Set to 1 to show plots or 0 to just do the calculations.
modefit = CalcModesFn(x,y);

numberofmodes = size(modefit(1).an,2);  
t = 1:size(modefit,2);
time = t.*exposureTime;
modes = 1:numberofmodes;
modestring = num2str(modes');
%Arbitrary spacer for the mode plot. Increase if modes are grouped too
%closely in the x-axis and vice versa
spacer = (10/8)*time(end);

%Create an array of mode amplitudes where rows are frames and columns are
%modes
a = zeros(size(modefit,2),numberofmodes);
snake = zeros(size(modefit,2),numberofmodes);
for frames = 1:size(modefit,2)
    a(frames,:) = modefit(frames).an;
    snake(frames,1:size(modefit(frames).s,1)) = modefit(frames).s(:)';
    %If the snake gets shorter, pad the ends with NaNs
    if size(modefit(frames).s,1)<size(snake,2)
        snake(frames,size(modefit(frames).s,1)+1:size(snake,2)) = NaN;       
    end
    Lfull(frames) = modefit(frames).L;
end

%Fit a normal distribution to each mode
for modes = 1:size(a,2)
    dist = fitdist(a(:,modes),'Normal');
    fModeFitDist(modes) = dist;
    fModeMean(modes)= dist.mu;
end



%%
%Plotting
if isplot;
    %Plot mode amplitudes
    figure;
    hold on;
    for mode = 1:size(a,2)
        plot(time+((mode-1)*spacer),a(:,mode),'.','MarkerSize',20);
        plot(mean(time)+((mode-1)*spacer),fModeMean(mode),'x','MarkerEdgeColor','black','MarkerSize',20,'LineWidth',2);
    end
    xlabel('Mode');
    ylabel('Amplitude (\mum^{-1/2})');
    title('Mode amplitudes over time');
    set(gca,'XTick',0:(max(time)+(size(a,2))*spacer)/numberofmodes:(max(time)+(size(a,2))*spacer)-spacer);       
    set(gca,'XTickLabel',modestring);

    %Plot length over time
    figure;
    plot(Lfull);
    xlabel('Frames');
    ylabel('Contour length (\mum)');
    

    %Plot the actual angle and the Fourier estimated angle to check that
    %decomposition has worked well enough
    figure;
    plot(modefit(1).s,modefit(1).Theta+mean(modefit(1).tangents),'r')
    hold on; scatter(modefit(1).smid,modefit(1).tangents,'r')
    title('Measured tangent angle and Fourier decomposition angle')
    legend('Fourier','Measured')
    xlabel('Arclength (\mum)');ylabel('Tangent Angle (rad)');
end


%%
%Save to struct
if exist(structPath,'file') == 0
    Fourier(1).Video = Images(1).name;
    Fourier(1).SourceFile = file;
    Fourier(1).s_um = snake;
    Fourier(1).L_um = Lfull;
    Fourier(1).an = a;
    Fourier(1).anMean = fModeMean;
    Fourier(1).ExposureTime_s = exposureTime;
    save(structPath,'Fourier');
else
    load(structPath)
    ii = tubNum;
    Fourier(ii).s_um = snake;
    Fourier(ii).L_um = Lfull;
    Fourier(ii).an = a;
    Fourier(ii).anMean = fModeMean;
    Fourier(ii).ExposureTime_s = exposureTime;
    save(structPath,'Fourier');
end
clear