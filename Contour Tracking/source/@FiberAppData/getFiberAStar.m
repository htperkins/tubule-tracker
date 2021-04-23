%Function by Hannah Perkins
%Modified version of getFiberAStar
function [xdata, ydata] = getFiberAStar(this,ii)
if ii == 1
    [x,y] = getpts;
else
    x = this.imageData(1,ii-1).xy{1,1}(1,:);
    y = this.imageData(1,ii-1).xy{1,1}(2,:);
end
    [xi, yi] = utility.searchPath(this.im, this.fiberIntensity*0.607, ...
                round(x(end)), round(y(end)), round(x(1)), round(y(1)));

    % Initialise data and creating "empty" dashed line
    xdata = [];
    ydata = [];
    seg_length = [];
    % If we couldn't find a path
    if isempty(xi)
        xdata = [];
        ydata = [];
        %resume(hObject);
        errordlg('Could not find a path', 'A* Error');
        return
    end

    xdata = [xdata, xi(2:end)];
    ydata = [ydata, yi(2:end)];
    seg_length(end+1) = length(xi) - 1;

