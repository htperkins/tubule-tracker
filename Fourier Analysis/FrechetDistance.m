%Function by Hannah Perkins
%Calculates the discrete Frechet distance between two polygonal lines
% Follows the pseudo code set out in Section 2.2 of 
% doi:10.1016/j.comgeo.2004.05.004
%The inputs should be points along two lines, with data being in one row
%over multiple columns

function fd = FrechetDistance(x1,y1,x2,y2)
    %Check that the data is input as vectors
    if ~isvector(x1) || ~isvector(y1) ||~isvector(x2) || ~isvector(y2)
        disp('Inputs must be vectors');
    elseif size(x1,2) < size(x1,1)
        x1 = x1';
        y1 = y1';
        x2 = x2';
        y2 = y2';
    end
    
    %Set up a matrix to fill with frechet distance values
    fd = zeros(size(x1,2),size(x2,2));
    
    %Calculate the Frechet distance
    %First find the distance between the first points
    fd(1,1) = distCalc(x1(1),y1(1),x2(1),y2(1));
    %Loop through to find the values to fill the first row
    for jj = 2:size(x2,2)
        fd(1,jj) = max([fd(1,jj-1) distCalc(x1(1),y1(1),x2(jj),y2(jj))]);
    end
    %Loop through to find the values for the first column. After each has
    %been caluclated, also fill in the applicable inner values
    for ii = 2:size(x1,2)
        fd(ii,1) = max([fd(ii-1,1) distCalc(x1(ii),y1(ii),x2(1),y2(1))]);
        for k = 2:size(x2,2)
            prevFD = [fd(ii,k-1) fd(ii-1,k) fd(ii-1,k-1)];
            fd(ii,k) = max([min(prevFD) distCalc(x1(ii),y1(ii),x2(k),y2(k))]);
        end       
    end
    
    %The discrete Frechet distance is the final value of the matrix
    fd = fd(end);
    
    function euclidD = distCalc(xp,yp,xq,yq)
        diffx = xp-xq;
        diffy = yp-yq;
        euclidD = sqrt(diffx^2 + diffy^2);
    end
end