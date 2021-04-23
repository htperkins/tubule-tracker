%Function by Hannah Perkins to compare Frechet distances of two vectors
%that have different sizes

function [v1start,v1end,v2start,v2end] = VectorComparison(v1x,v1y,v2x,v2y)
%Remove NaNs
v1x(isnan(v1x)) = [];
v2x(isnan(v2x)) = [];
v1y(isnan(v1y)) = [];
v2y(isnan(v2y)) = [];
%Check the difference in vector lengths
v1len = size(v1x,1);
v2len = size(v2x,1);
ldiff = v2len-v1len;
%The number of different combinations is given by the length difference
%plus one. Therefore, the shift between the two vectors goes from zero to
%the length difference
if ldiff > 0
    for shift = 0:ldiff;
        fd(shift+1) = FrechetDistance(v1x,v1y,v2x(shift+1:end+shift-ldiff),v2y(shift+1:end+shift-ldiff));
    end
    %Find the minimum Frechet distance
    [~,I] = min(fd);
    %Output the indicies of each vector
    v1start = 1; v1end = v1len;
    v2start = I;
    v2end = v2len+I-1-ldiff;
elseif ldiff < 0 
    for shift = 0:ldiff;
        fd(shift) = FrechetDistance(v1x(shift+1:end+shift-ldiff),v1y(shift+1:end+shift-ldiff),v2x,v2y);
    end
    %Find the minimum Frechet distance
    [~,I] = min(fd);
    %Output the indicies of each vector
    v2start = 1; v2end = v2len;
    v1start = shift(I)+1;
    v1end = v1len+shift(I)-ldiff;
else
    error('Vectors seem to be the same length');
end

