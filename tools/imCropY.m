function imOut = imCropY(imIn)
    
    [Nx,Ny] = size(imIn);

    % Computing the standard deviation at the top and bottom to detect any
    % big change in the intensity that would indicate an edge. 20 rows are
    % used to average out the effect of the noise when taking the gradient
    
    s1 = sum(imIn(5:25,2:end-1),1); % top rows averaged for noise
    s2 = sum(imIn(end-25:end-5,2:end-1),1); % same for bottom region
    
    % Compute gradient
    s1Grad = abs(gradient(s1));
    s2Grad = abs(gradient(s2));
    
    % Normalization
    s1Grad = s1Grad/max(s1Grad(:));
    s2Grad = s2Grad/max(s2Grad(:));
    
    % Locating the possible peaks
    % The first and last pixels are left to avoid side effects 
    [pks1,locPks1] = findpeaks(s1Grad,linspace(2,Ny-1,Ny-2),'MinPeakHeight',0.6,'MinPeakDistance',round(0.4*Nx));
    [pks2,locPks2] = findpeaks(s2Grad,linspace(2,Ny-1,Ny-2),'MinPeakHeight',0.6,'MinPeakDistance',round(0.4*Nx));
    
    % Noise test
    % If the image contains no edge in this direction the noise will play
    % the major role. Thus many peaks should be detected. If it is the case
    % the detected peaks pks are reset to an empty array
    [noiseTest,~] = findpeaks(s1Grad,linspace(2,Ny-1,Ny-2),'MinPeakHeight',0.5,'MinPeakDistance',round(0.05*Nx));
    if length(noiseTest)>2
        pks1 = [];
    end
    % Same noise test for the bottom region
    [noiseTest,~] = findpeaks(s2Grad,linspace(2,Ny-1,Ny-2),'MinPeakHeight',0.5,'MinPeakDistance',round(0.05*Nx));
    if length(noiseTest)>2
        pks2 = [];
    end
    
    % No edge detected -> keep the all image
    if isempty(pks1)==1 && isempty(pks2)==1
        yMin = 1;
        yMax = Ny;
    % Edge detected in the bottom region
    elseif isempty(pks1)==1 && isempty(pks2) == 0
        % One edge found so only one side need to be cropped
        if length(pks2)==1
            % Left or right side ?
            if locPks2>0.5*double(Ny)
                yMin=1;
                yMax=locPks2-5;
            else
                yMin=locPks2+5;
                yMax=Ny;
            end
        % More than one edge detected    
        else
            % Take the two biggest peaks that are supposed to represent the
            % two edges
            [~,indSort] = sort(pks2,'descend');
            locPks3Sort = locPks2(indSort(1:2));
            yMin = min(locPks3Sort);
            yMax = max(locPks3Sort);
        end
    % The same for the top region
    elseif isempty(pks1)==1 && isempty(pks2) == 0
        if length(pks1)==1
            if locPks1>0.5*double(Ny)
                yMin=1;
                yMax=locPks1-5;
            else
                yMin=locPks1+5;
                yMax=Ny;
            end
        else
            [~,indSort] = sort(pks1,'descend');
            locPks2Sort = locPks1(indSort(1:2));
            yMin = min(locPks2Sort);
            yMax = max(locPks2Sort);
        end
    % Edges detected in both top and bottom region
    else
        locPks2Sort = locPks1;
        locPks3Sort = locPks2;
        if length(pks1)>2
            [~,indSort] = sort(pks1,'descend');
            locPks2Sort = locPks1(indSort(1:2));
        end
        if length(pks2)>2
            [~,indSort] = sort(pks2,'descend');
            locPks3Sort = locPks2(indSort(1:2));
        end
        % Crop as much as possible (in case of tilted image for example)
        yMin = max([min(locPks2Sort),min(locPks3Sort)])+5;
        yMax = min([max(locPks2Sort),max(locPks3Sort)])-5;
        
        if yMax<0.5*double(Ny)
            yMax=Ny;
        end
        if yMin>0.5*double(Ny)
            yMin=1;
        end
    end
    imOut = imIn(:,yMin:yMax);

end