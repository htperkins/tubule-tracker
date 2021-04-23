% Given the data in x and y (must be same length), calculate the fourier
% modes (0,1,...,n) to describe the shape of (x,y).
% Written by Henry Cox, 01/11/17

function [an,L,s,tangent,Theta,smid] = NumericalFModes(x,y,n)

% check dimensions are the right way around
if size(x,1) == 1
    x = x';
end
if size(y,1) == 1
    y = y';
end

%Check that the number of points found along the fibre is at least 2
%greater than the number of modes to fit
while size(x,1) - 2 < n 
    n = n -1;
    if n < 4
        error(['Insufficient number of points tracked to fit ' num2str(n)...
      	 ' modes. Only ' num2str(size(x,1)) ' points tracked. '...
       	 num2str(n+2) ' is the minimum number of points required in this case.'])
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find the scalar, s, distance along the contour described by (x,y)
dx = diff(x);
dy = diff(y);
ds = sqrt(dx.^2+dy.^2);
s = 0;
for k = 1: length(ds)
    s = [s; sum(ds(1:k))];
end

% find the midpoint of each segment on the contour
smid = s(1:end-1) + (s(2:end)-s(1:end-1))./2;

% find the length of the contour
L = s(end);

% Check if the Nyquist-Shannon sampling theorem is satisfied. See Fourier
% Analysis google doc, point 3, for details
if L < n*s(2)
    error(['The length of the fibre is too short to fit '...
        num2str(n) ' modes'])
end
% find the tangent angle at each point on the contour
tangent = unwrap(atan2(dy,dx));%atan(dy./dx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start calculating the fourier modes
% an = sqrt(2/L)*sum(tangent*s*cos((n*pi*smid)/L))

% first calculate tangent*ds
TS = tangent.*ds;

% calculate inside of cos term
incos = pi().*smid./L;

% finally calculate an
for i = 1:n
    an(i) = sqrt(2/L)*sum(TS.*cos(i.*incos));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now reverse the calculation to generate the tangent angles to evaluate
% the fitting
% Theta(s) = sum(Thetan(s))
% Thetan(s) = sqrt(2/L)*an*cos(n*pi*s/L)

% calculate pi*s/L
incos2 = pi().*s./L;
%incos2 = pi().*linspace(0,1,100);
nvals = 1:n;

% calculate new tangent, Theta
for i = 1:length(incos2)
    Theta(i) = sqrt(2/L)*sum(an.*cos(nvals.*incos2(i)));
end

end

