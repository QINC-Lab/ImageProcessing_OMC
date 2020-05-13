function imContrast =  imCheckContrast(imBW)
    
    % Morphological closing
    imBWC = imclose(imBW,strel('square',5));

    % Compute the mean difference
    diff = abs(imBW-imBWC);
    
    % Mean diff over 
    mDiff = mean(diff(:));
%     disp(mDiff);
    if mDiff<0.0035
        imContrast = 1;
    else
        imContrast = 0;
    end
end