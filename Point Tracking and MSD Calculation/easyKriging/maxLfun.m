function [thetaMLE,muMLE,sigmaMLE,lval] = maxLfun(samples,points,corFun,lowerTheta,upperTheta)
% maxlfun() returns the maximum likelihood values of mu, sigma and theta.
%
% Input:
% samples - nx by nSamples matrix
% points - spatial locations of samples
% corFun - desired correlation function: 'exp','sexp','poly','tri'
% lowerTheta (optional) - lower bound on correlation length
% upperTheta (optional) - upper bound on correlation length
%
% Output:
% thetaMLE - estimated correlation length
% muMLE - estimated mean
% sigmaMLE - estimated standard deviation
% lval - likelihood value

    f = @(theta) -lfun(samples,calcCorrMat(points,corFun,theta));
    optionsfmin = optimset('Display','off');
    thetaMLE = fminbnd(f,lowerTheta,upperTheta,optionsfmin);
    [lval,muMLE,sigmaMLE] = lfun(samples,calcCorrMat(points,corFun,thetaMLE));
    
    if thetaMLE == upperTheta
        printf('Consider increasing upperbound')
    end
    
end

