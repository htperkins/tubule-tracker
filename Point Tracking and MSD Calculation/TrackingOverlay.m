%Function by Hannah Perkins
%Overlays the results of MSDTracking.m onto the original video
function TrackingOverlay(filename,xline,yline,midpoint,varargin)

%Change to zero if you don't want to save the video with overlay
issave = 0;
figure;
if issave;
    if exist([filename 'MSDTracking.avi'], 'file');
        ii = 1;
        while exist([filename '(' num2str(ii) ')MSDTracking.avi'], 'file');
            ii = ii+1;
        end
        vidname = [filename '(' num2str(ii) ')Tracking.avi'];
    else
        vidname = [filename 'MSDTracking.avi'];
    end
    v = VideoWriter(vidname);open(v);
end
angle = atan((yline(2)-yline(1))/(xline(2)-xline(1)));

if isempty(varargin)
    for frame = 1:size(midpoint,2)
        im = imread([filename '.tif'],frame);
        %im = imadjust(im, [0 .1]);
        imshow(im,'InitialMagnification','fit');
        hold on;
        x = xline(1)+midpoint(frame)*cos(angle);
        y = yline(1)+midpoint(frame)*sin(angle);
        plot(x,y,'ro','MarkerSize',10);
        text(1,1,num2str(frame),'Color','green','FontSize',18);
        drawnow;
        if issave;
            currframe = getframe(gcf);
            writeVideo(v,currframe);
        end
        clf;
    end
else
    for frame = 1:size(varargin{1},2)
        im = imread([filename '.tif'],frame);
        im = imadjust(im, [0 .1]);
        imshow(im);
        hold on;
        x = imageData(1,frame).xy{1}(1,:);
        y = imageData(1,frame).xy{1}(2,:);
        plot(x,y,':r*');
        data2 = varargin{1};
        x2 = data2(1,frame).xy{1}(1,:);
        y2 = data2(1,frame).xy{1}(2,:);
        plot(x2,y2,':m+');
        text(15,15,num2str(frame),'Color','white','FontSize',18);
        drawnow;
        if issave;
            currframe = getframe(gcf);
            writeVideo(v,currframe);
        end
    end
end

if issave;
    close(v);
else 
    close
end