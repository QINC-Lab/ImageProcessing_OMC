function sOut = imAnalyze(imPath)
% Function that analyzes the image of .tif format in the imPath folder 
% (default value if not specified: current path). The output is a structure
% containing for every image files :
%   - 

    % Set default path
    if nargin<1
        imPath = pwd;
    end
    
    % Loading the images files
    if strcmp(imPath(end),'\')==1
        imDir = strcat(imPath,'*.tif');
    else
        imDir = strcat(imPath,'\*.tif');
    end
    imFiles = dir(imDir);
    
    % Loop on all the images
    for kIm = 1:length(imFiles)
        im = imread(imFiles(kIm).name);
        
        % Crop the image banner at the bottom
        im = im(1:692,:);
        
        % Crop a part of the background
        im = imCrop(im);
        
        % Noise filter
        im = wiener2(im);
        
        % Image thresholding using historgram
        [counts,centers] = hist(double(im(:)),30);
        [peaks,locPeaks] = findpeaks(counts,centers,'MinPeakDistance',30);
        [~,indSorting]=sort(peaks,'descend');
        sortedLocPeaks = locPeaks(indSorting);
        thr = mean(sortedLocPeaks(1:2))/255;
        
        imBW = im2bw(im,thr);
        
        figure;imshow(imBW)
        
        % Detecting boundaries
        boundaries = bwboundaries(imBW,4);
        beam = boundaries{1};
        holes = boundaries(2:end);
        
        % Interpolation of the edge points
        % Shifted duplication of the image
        Ixm1 = double(im(1:end-2,2:end-1));
        Ixp1 = double(im(3:end,2:end-1));
        Iym1 = double(im(2:end-1,1:end-2));
        Iyp1 = double(im(2:end-1,3:end));

        % Computation of the directional gradients
        Gx = 0.5*abs(Ixp1-Ixm1);
        Gy = 0.5*abs(Iyp1-Iym1);
        
        % Edges analysis : Beam
        %  -  Remove small edges
        horizEdges = beam(and(beam(:,2)>min(beam(:,2))+1,beam(:,2)<max(beam(:,2))-1),:); % + and -1 because of the cropping due to the gradient
        %  -  Divide the top and bottom egdes
        topEdge = horizEdges(horizEdges(:,1)<mean(horizEdges(:,1)),:);
        bottomEdge = horizEdges(horizEdges(:,1)>mean(horizEdges(:,1)),:);

        % Interpolate the 'mass' center coordinate couples of the gradient map
        [ny,nx] = size(im);
        [Xcoord,Ycoord] = meshgrid(2:nx-1,2:ny-1); % From 2 to end-1 because of the cropping due to the gradient

        [Xinterp,Yinterp] = interpolateMassCenter(Xcoord,Ycoord,Gx,Gy);

        topEdgeXinterp = diag(Xinterp(topEdge(:,1)-2,topEdge(:,2)-2)); % -2 factor due to the cropping from the gradient and the interpolation
        topEdgeYinterp = diag(Yinterp(topEdge(:,1)-2,topEdge(:,2)-2));
        bottomEdgeXinterp = diag(Xinterp(bottomEdge(:,1)-2,bottomEdge(:,2)-2));
        bottomEdgeYinterp = diag(Yinterp(bottomEdge(:,1)-2,bottomEdge(:,2)-2));

        % Fitting straight lines
        pTop = polyfit(topEdgeXinterp,topEdgeYinterp,1);
        %pTopRaw = polyfit(topEdge(:,2),topEdge(:,1),1);
        pBottom = polyfit(bottomEdgeXinterp,bottomEdgeYinterp,1);
        %pBottomRaw = polyfit(bottomEdge(:,2),bottomEdge(:,1),1);
        % Compute "ideal" edges lines
        topIdealEdge = polyval(pTop,topEdgeXinterp);
        %topIdealEdgeRaw = polyval(pTopRaw,topEdge(:,2));
        bottomIdealEdge = polyval(pBottom,bottomEdgeXinterp);
        %bottomIdealEdgeRaw = polyval(pBottomRaw,bottomEdge(:,2));
        % Compute residuals
        resTop = topEdgeYinterp-topIdealEdge;
        %resTopRaw = topEdge(:,1)-topIdealEdgeRaw;
        resBottom = bottomEdgeYinterp-bottomIdealEdge;
        %resBottomRaw = bottomEdge(:,1)-bottomIdealEdgeRaw;
        
        %Edges analysis : Holes
        j = 1;
        for i=1:length(holes)
            holesY = holes{i}(:,1);
            holesX = holes{i}(:,2);
            if max(holesX)<nx-2 && min(holesX)>2 && max(holesY)<ny-2 && min(holesY)>2
                holesXinterp = diag(Xinterp(holesY-2,holesX-2)); % -2 factor due to the cropping from the gradient and the interpolation
                holesYinterp = diag(Yinterp(holesY-2,holesX-2));

                elip{j} = fit_ellipse(holesXinterp,holesYinterp);

                deltaR{j} = computeEllipseResiduals(elip{j},holesXinterp,holesYinterp); 
                j = j+1;
            end
        end
        
        %sOut{kIm} = struc('topBeamResiduals',resTop,'bottomBeamResiduals',resBottom,'holesResiduals',{deltaR}); % Change here
    end
    

end