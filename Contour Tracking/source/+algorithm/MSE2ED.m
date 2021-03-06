function [xdata, ydata, count] = MSE2ED(data, step, procStepNum)
%MSEND2ENDDISTANCE Mean-Square End-to-End Distance

xdata = step*(1:procStepNum);
ydata = zeros(1, procStepNum); % mean square end-to-end distance
count = zeros(1, procStepNum); % weight of each graph point

for k = 1:length(data)    
    xy = data{k}; % coordinates of the current fiber
    
    n = length(xy); % number of points in the current fiber
    
    shiftNum = min(procStepNum, n-1);
    
    count(1:shiftNum) = count(1:shiftNum) + (n-1:-1:n-shiftNum);
    
    % Cycle for different separations between points along a fiber
    for l = 1:shiftNum
        ydata(l) = ydata(l) + ...
            sum( sum( ( xy(:,1:end-l) - xy(:,1+l:end) ).^2 ) );
    end
end

ydata = ydata./count;

