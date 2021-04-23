function SNR = CheckSNR(r,intensity)
    %INTEGRATED INTENSITY SECTION
    %Find integrated intensity by first inverting the signals and finding
    %maxima to find the local minima at the edges of the profile
    inv = max(intensity)-intensity;
    %Find the maximum intensity and therefore the guess of the midpoint.
    %Ignore the first and last points
    [~,ind] = max(intensity(2:end-1));
    %Correct for skipping the first point
    ind = ind+1;
    %Find local minima by finding peaks in the inverted signals, for both
    %the first and second half of the data separately. Not including oeak
    %or points adjacent to peak so that noise at the peak is disregarded
    %Only use findpeaks if there is enough data (3 or more points),
    %otherwise just set as the local inverted maximum value (same as
    %minimum in signal)
    if size(inv(1:ind-1),1) < 3
        [lowpk,lowloc] = max(inv(1:ind-1));
    else
        [lowpk,lowloc,~,lowprom] = findpeaks(inv(1:ind-1));
    end
    %If low value is empty, set it to the first point in the series
    if isempty(lowpk)
        lowpk = inv(1);
        lowloc = 1;
    %If there are multiple minima, pick the most prominent
    elseif length(lowpk)>1
       [~,lind] = max(lowprom);
       lowpk = lowpk(lind);
       lowloc = lowloc(lind);
    end
    
    %Repeat, but search for minima at high end of signal
    if size(inv(ind+1:end),1) < 3
        [hipk,hiloc] = max(inv(ind+1:end));
    else
        [hipk,hiloc,~,hiprom] = findpeaks(inv(ind+1:end));
    end
    if isempty(hipk)
        hipk = inv(end);
        hiloc = size(intensity,1)-ind;
    elseif length(hipk)>1
       [~,hind] = max(hiprom);
       hipk = hipk(hind);
       hiloc = hiloc(hind);
    end
    
    %Set up peak and location vectors
    pks = [lowpk(end);hipk(1)];
    
    %Need to add the index of the peak values to the high locations to
    %correct for search region
    locs = [(lowloc);(hiloc+ind)];
    
    %Switch peak values back to signal from inverted signal
    pks = max(intensity)-pks;
    
    %Find the line between the local minima
    coeffs = polyfit(r(locs),pks,1);
    
    %Use trapezoidal numerical integration to find the area between the
    %original intensity profile and the line between the minima at the
    %edges of the signal. This is the integrated intensity SNR
    SNR = trapz(intensity(locs(1):locs(2)))-...
        trapz(polyval(coeffs,r(locs)));
    