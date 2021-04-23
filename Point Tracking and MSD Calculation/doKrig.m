%Function by Hannah Perkins 05/2020 to krig data.
%This is a method of interpolation that keeps the originally measured
%points and estimates the points between them using maximum likelihood.
%Uses scripts from 'easyKriging' https://uk.mathworks.com/matlabcentral/fileexchange/66136-easykriging

%INPUTS: x - values at which the original data is sampled (eg. distance)
%        y - values of the original data (eg. intensity)
%        nPoints - size of the resampled data

%OUTPUTS: uncondPoints - vector of points at which the interpolated data is
%                         sampled
%         krige - interpolated values of the data

function [uncondPoints,krige] = doKrig(x,y,nPoints)

%set to zero to stop plotting comparison and confidence intervals
isplot = 0;
%Make the vector of points at which to evaluate y
uncondPoints = linspace(0,x(end),nPoints)';

%Use a Gaussian-type function as the correlation. Can also use 'exp','poly'
%or 'tri'
corFun = 'sexp';
%Set bounds over which to search for the correlation length
lowerTheta = 0;
upperTheta = 100;

%Find the correlation length (theta), mean and standard deviation for the
%maximum likelihood
[theta,mu,sigma,~] = maxLfun(y,x,corFun,lowerTheta,upperTheta);

%If the range of theta values is too large, the function maximisation can
%find complex roots. If this happens, readjust the bounds for theta and try
%again.
while ~isreal(theta) || ~isreal(mu) || ~isreal(sigma)
    upperTheta = 0.5*upperTheta;
    [theta,mu,sigma,~] = maxLfun(y,x,corFun,lowerTheta,upperTheta);
    if upperTheta < 2
        print(['Maximisation threshold is too small. The function has'...
            'failed to find an appropriate value of theta']);
    end
end
%Interpolate by kriging with the maximum likelihood values
[krige,CIupper,CIlower] = krigeIt(x,y,uncondPoints,corFun,mu,sigma,theta);

if isplot
    %Plot the original data and the krigged points
    figure;
    hold on
    X = [uncondPoints; flipud(uncondPoints)];
    Y = [CIlower; flipud(CIupper)];
    Y(isnan(Y)) = 0;
    h = fill(X',Y',[0.8,0.8,0.8]);
    set(h,'EdgeColor','none')
    scatter(x,y,'MarkerEdgeColor',[1 0 0],'LineWidth',1,'Marker','o','SizeData',50,'LineWidth',1,'MarkerFaceColor',[1,0,0]);
    plot(uncondPoints,krige,'color',[1 0 0],'LineWidth',2)
    legend('95% Confidence Intervals','Original Data','Krig Interpolation')
    box on
end