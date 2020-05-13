function imOut = imThresholding(imIn)

    % Computing the image historgram for the threshold estimation
    [counts,centers] = hist(double(imIn(:)),30);
    % Normalization 
    counts = counts/max(counts(:));

    minHeight = 0.2;
    minDist = 30;
    
    % Determination of the histogramm peaks usually there are one or
    % severals background peaks with lower values and one smaller peak with
    % bigger values
    [peaks,locPeaks] = findpeaks(counts,centers,'MinPeakDistance',30,'MinPeakHeight',0.2);
    
    % Depending on the image and the contrast the peak detection has to be
    % changed
    while length(peaks)<2 && minHeight>=0.05
        minDist = minDist - 2;
        minHeight = minHeight - 0.04;
        [peaks,locPeaks] = findpeaks(counts,centers,'MinPeakDistance',minDist,'MinPeakHeight',minHeight);
    end
    
    if length(peaks)>1
        % Sorting the peaks to identify the background one and the beam one
        sortedLocPeaks = sort(locPeaks,'descend');

        % Set the threshold in between
        %thr = mean(sortedLocPeaks(1:2))/255;

        % Find the minimum between the two peaks
        minCounts = min(counts(and(centers>sortedLocPeaks(2),centers<sortedLocPeaks(1))));

        % Threshold at this position
        thr = round(mean(centers(counts==minCounts)))/255;
    else
        thr = locPeaks/255;
    end
    
    % Black and white image with thresholding
    imOut = im2bw(imIn,thr);

    % Display black and white image if needed
    %figure;imshow(imBW);

end