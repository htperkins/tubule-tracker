function [x0,profFit] = profileFit(r,intensity,model,opts)
    [maxInt,ind] = max(intensity(2:end-1));
    %Correct for skipping the first point 
    ind = ind+1; 
    gaussMid = r(ind);
    %Set the offset to the minimum value of the signal
    offs = min(intensity);
    %Find points where signal drops to half of the peak height
    %(above the offset). Use this to find upper and lower limits
    %Find the intensity value halfway between the offset and the peak
    comp = offs+(0.5.*(maxInt-offs));
    %Find which intensity value is closest to this, above and below the
    %peak. Choose the value closest to the peak so that edge effects do not
    %contribute
    lowerlim = find(diff((intensity(1:ind)-comp)>=0),1,'last');
    upperlim = find(diff((intensity(ind:end)-comp)>=0),1,'first');
    %Correct for indicies in upper minimum finding
    upperlim = upperlim + ind;
    %If this method doesn't find a value, set it to the local minimum
    if isempty(lowerlim)
        [~,lowerlim] = min(intensity(1:ind));
    end
    if isempty(upperlim)
        [~,upperlim] = min(intensity(ind:end));
        %Correct for indicies in upper minimum finding
        upperlim = upperlim + ind -1;
    end
    
    %Set sigma parameter guess to half of the Gaussian FWHM
    gaussSig = 0.5*(r(upperlim)-r(lowerlim));
    %Set up fitting initial parameter matrix
    x0 = [maxInt-offs; gaussSig; gaussMid; offs];
    
    %%
    %FITTING
    %Use iteratively reweighted least squares fitting, with a Cauchy error
    %model. This expects more extreme outliers in the profile and can fit
    %the rest of the data while ignoring outliers.
    profFit = nlinfit(r,intensity,model,x0,opts);