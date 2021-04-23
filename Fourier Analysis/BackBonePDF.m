%Function by Hannah Perkins
%Designed to find the mean backbone of a tubule and the pdf of the
%displacements from the backbone.
%The variance and skew of these pdfs is analysed to find traces of active
%motion

function [Fourier] = BackBonePDF(Fourier,FourierPath,tub)

%To save graphs, set to 1 and define which folder to save in
toSave = 1;

load(Fourier(tub).SourceFile);
%For one tubule, loop through frames and get the x,y data
for ii = 1:size(imageData,2)
    id = imageData(1,ii).xy{1, 1};
    x(1:size(id,2),ii) = id(1,:);
    y(1:size(id,2),ii) = id(2,:);
end
%If length changes, set assigned zeros to NaNs
x(x==0) = NaN;
y(y==0) = NaN;
%Decide if you want to remove length changes
removeLChange = 1;
%Find the maximum number of appended NaNs
numAppend = max(sum(isnan(x)));
%Find where the changes in length occur
%lchange gives 0 if the length doesn't change
nanVals = sum(isnan(x));
lchange = diff(sum(isnan(x)));
lchangepos = find(lchange);
%Before starting, remove any transient changes from the first 5% of
%the data points
if find(lchange(1:floor(0.05*size(x,2))) < -1);
    %If any length changes greater than 1 happen in the first 5%,
    %just start x and y after these
    largeCh = find(lchange(1:floor(0.05*size(x,2))) < -1);
    x = x(:,largeCh(end)+1:end);
    y = y(:,largeCh(end)+1:end);
    %Update values
    numAppend = max(sum(isnan(x)));
    nanVals = sum(isnan(x));
    lchange = diff(sum(isnan(x)));
    lchangepos = find(lchange);
end
%If there are still length changes, fix this
if removeLChange && numAppend ~= 0 
    %Loop through the position changes, deciding which points along the
    %line to keep by testing the Frechet distance
    endPoint = size(x,1)-numAppend;
    xnew = x(1:endPoint,1:lchangepos(1)); ynew = y(1:endPoint,1:lchangepos(1));
    for pos = 1:length(lchangepos)
        %Compare the last column of the new vector to the next column
        %of the old one
        [new1start,new1end,new2start,new2end] = ...
            VectorComparison(xnew(:,end),ynew(:,end),...
            x(:,lchangepos(pos)+1),y(:,lchangepos(pos)+1));
        %Assign the results to x and y new for the next run of this
        %loop - works if tubule gets longer
        if pos == length(lchangepos)
            %If its the last value to check, just put the final column
            %as the end colum
            xnew = [xnew x(new2start:new2end,lchangepos(pos)+1:end)];
            ynew = [ynew y(new2start:new2end,lchangepos(pos)+1:end)];
        else
            %If its not the last value to check, only fill the new
            %values up until the next length change
            xnew = [xnew x(new2start:new2end,lchangepos(pos)+1:lchangepos(pos+1))];
            ynew = [ynew y(new2start:new2end,lchangepos(pos)+1:lchangepos(pos+1))];
        end

    end
    %Reassign x as xnew
    x = xnew; y = ynew;
end

%Save the updated x and y co-ordinates to the Fourier Struct for
%Fourier Analysis
Fourier(tub).xCoords_pix = x;
Fourier(tub).yCoords_pix = y;


%Find the mean x and y values = BACKBONE
meanX = nanmean(x');
meanY = nanmean(y');

%Rotating the x and y values so that ther x-direction corresponds to
%the line of the backbone and any y-displacements are (roughly)
%perpendicular to the tubule backbone
%figure;plot(meanX,meanY)
%Move end closest to zero to(0,0)
firstDist = sqrt(meanX(1).^2 + meanY(1).^2);
lastDist = sqrt(meanX(end).^2 + meanY(end).^2);
if firstDist < lastDist
    shiftmeanX = meanX - meanX(1);
    shiftmeanY = meanY - meanY(1);
    shiftx = x - meanX(1);
    shifty = y - meanY(1);
    %Find the angle from the end point to the x-axis
    angle = -1*atan2(shiftmeanY(end),shiftmeanX(end));
elseif lastDist<firstDist
    shiftmeanX = meanX - meanX(end);
    shiftmeanY = meanY - meanY(end);
    shiftx = x - meanX(end);
    shifty = y - meanY(end);
    %Find the angle from the end point to the x-axis
    angle = -1*atan2(shiftmeanY(1),shiftmeanX(1));
end
%hold on;plot(shiftmeanX,shiftmeanY)
%Rotate the shifted values by the angle
shiftmean = [shiftmeanX; shiftmeanY];
%Make the x and y matrices into a 2D x-y vector
shiftAll = [reshape(shiftx,[size(x,1)*size(x,2),1]) ...
    reshape(shifty,[size(x,1)*size(x,2),1])];
%Set up the rotation matrix
R = [cos(angle) -sin(angle); sin(angle) cos(angle)];
rotatedmean = R*shiftmean;
rotatedAll = R*shiftAll';
%Reshape the x and y vectors to be the same as the initial input
rotx = reshape(rotatedAll(1,:),size(shiftx));
roty = reshape(rotatedAll(2,:),size(shiftx));
%     hold on;
%     plot(rotx,roty)
%     plot(rotatedmean(1,:),rotatedmean(2,:),'k','LineWidth',5)

 %Find the displacement of each (x,y) point from the backbone
for point = 1:size(meanX,2)
    xDisp(point,:) = rotx(point,:) - rotatedmean(1,point);
    yDisp(point,:) = roty(point,:) - rotatedmean(2,point);
end
disp = sqrt(xDisp.^2 + yDisp.^2);
%Save the displacements to the struct
Fourier(tub).xDisp_pix = xDisp;
Fourier(tub).yDisp_pix = yDisp;

%Find the skewness
xskew = skewness(xDisp,0,2);
yskew = skewness(yDisp,0,2);
%Find the standard error of skewness (SES)
w = size(xDisp,2);
SES = sqrt(6*w*(w-1)/((w-2)*(w+1)*(w+3)));
%If the absolute value of the skewness is > 3.29 * the SES, skewness is
%significant for larger sample sizes (doi:10.5395/rde.2013.38.1.52)
xskewSig(1:size(meanX,2),tub) = abs(xskew) > 3.29*SES;
yskewSig(1:size(meanY,2),tub) = abs(yskew) > 3.29*SES;
%Find the values of the significant skewness
xskewS(1:size(meanX,2),tub) = xskew.*xskewSig(1:size(meanX,2),tub);
yskewS(1:size(meanY,2),tub) = yskew.*yskewSig(1:size(meanY,2),tub);

%Find the variance
xvar(1:size(meanX,2),tub) = var(xDisp,[],2,'omitnan');
yvar(1:size(meanY,2),tub) = var(yDisp,[],2,'omitnan');
%Find the total variance
totVar(1:size(meanX,2),tub) = sqrt(xvar(1:size(meanX,2),tub).^2 + yvar(1:size(meanX,2),tub).^2);


%Rotate the required values back to the original orientation
Rback = [cos(-angle) -sin(-angle); sin(-angle) cos(-angle)];
yskewS2 = Rback*[zeros(size(yskewS(:,tub),1),1) yskewS(:,tub)]';
xDisp2 = Rback*[reshape(xDisp,[size(xDisp,1)*size(xDisp,2),1]) reshape(yDisp,[size(xDisp,1)*size(xDisp,2),1])]';

xDispOr = reshape(xDisp2(1,:),[size(xDisp,1),size(xDisp,2)]);
yDispOr = reshape(xDisp2(2,:),[size(xDisp,1),size(xDisp,2)]);
%Plot the variance in the points along the backbone
h = figure;
plot(yvar(1:size(meanX,2),tub));
hold on;plot(xvar(1:size(meanX,2),tub));
legend('Perpendicular','Parallel')
xlabel('Position (pixels)')
ylabel('Variance (pixels^2)')
%Create temp versions of the variable with a NaN values added to the end. 
%This avoids a line joining the first and last points in the patch plot
ttotVar(1:size(meanX,2)+1,tub) = [totVar(1:size(meanX,2),tub); NaN];
%meanX and meanY refer to the original, untranslated and
%untransfored points
tmeanX = [meanX NaN]; tmeanY = [meanY NaN];
%Plot the backbone with the variance as a colour
figure
xlabel('x (pixels)')
ylabel('y (pixels)')
patch(tmeanX,tmeanY,ttotVar(1:size(meanX,2)+1,tub),'EdgeColor',...
    'interp','Marker','o','MarkerFaceColor','flat','FaceColor','none');
colorbar
%Also plot arrows for significant skew values
hold on;
counter = 1;
for point2 = 1:size(xskew,1)
    %Only plot the arrows if the skew perpendicular to the tubule is significant
    if yskewSig(point2,tub) == 1
        anArrow(counter) = annotation('arrow') ;
        anArrow(counter).Parent = gca;  % or any other existing axes or figure
        anArrow(counter).Position = [meanX(point2), meanY(point2), yskewS2(1,point2), yskewS2(2,point2)] ;
        counter = counter + 1;
    end
end


%Plot the backbone as a surface
%In order to find the surface, add the backbone to the displacement values
for jj = 1:size(xDisp,2);
    xpixels(1:size(xDispOr,1),jj) = xDispOr(:,jj) + meanX';
    ypixels(1:size(yDispOr,1),jj) = yDispOr(:,jj) + meanY';
end
%Reshape to a vector
xpixels = reshape(xpixels,[numel(xpixels),1]);
ypixels = reshape(ypixels,[numel(ypixels),1]);
%Plot the surface
nbinsx = floor(2.5*max(range(xpixels)));
nbinsy = floor(2.5*max(range(ypixels)));
figure;
hist3([xpixels ypixels],[nbinsx,nbinsy],'CDataMode','auto','FaceColor','interp')
view(2)
colorbar
xlabel('x (pixels)')
ylabel('y (pixels)')
%OPTIONAL - Wait for first figure to be closed before continuing
%This stops matlab from overloading itself
%uiwait(h);
%If toSave is on, save the images to the same folder as Fourier
%struct
if toSave
    FigName = [Fourier(tub).Video(1:end-4) 'VarSkew'];
    [filepath,~,~] = fileparts(FourierPath);
    savefig(h, fullfile(filepath,strcat(FigName,'.fig')));
end

%Saving
Fourier(tub).perpSignificantSkew = yskewS2(:,1:size(meanX,2));

%Clear all tubule-specific variables
clearvars -except Fourier toPlot toSave nonNorm percDist xskewSig yskewSig ...
    xvar yvar xskewS yskewS FourierPath


save(FourierPath,'Fourier');
