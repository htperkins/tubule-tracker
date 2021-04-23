%Function by Hannah Perkins
%Overlays the results of the FiberApp loop onto the original video
function CheckTracking(filename,imageData,varargin)

%Set to 1 to save or 0 not to
issave = 0;
figure;
if issave;
    if exist([filename 'Tracking.avi'], 'file');
        ii = 1;
        while exist([filename '(' num2str(ii) ')Tracking.avi'], 'file');
            ii = ii+1;
        end
        vidname = [filename '(' num2str(ii) ')Tracking.avi'];
    else
        vidname = [filename 'Tracking.avi'];
    end
    v = VideoWriter(vidname);
    open(v);
end

if isempty(varargin)
    for frame = 1:size(imageData,2)-5
        im = imread([filename '.tif'],frame+5);
        %im = imadjust(im, [0 .1]);
        imshow(im,'InitialMagnification','fit');
        hold on;
        x = imageData(1,frame).xy{1}(1,:);
        y = imageData(1,frame).xy{1}(2,:);
        plot(x,y,'r','LineWidth',4);
        text(1,1,num2str(frame),'Color','green','FontSize',18);
        drawnow;
        if issave;
            currframe = getframe(gcf);
            writeVideo(v,currframe);
        end
        clf
    end
else
    for frame = 1:size(varargin{1},2)
        im = imread([filename '.tif'],frame);
        %im = imadjust(im, [0 .1]);
        imshow(im,'InitialMagnification','fit');
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
        clf;
    end
end


if issave;
    close(v);
else
    close
end