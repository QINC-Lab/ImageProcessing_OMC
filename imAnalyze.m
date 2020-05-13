function [dose,meanRough] = imAnalyze(imPath,os)
% Function that analyzes the image of .tif format in the imPath folder 
% (default value if not specified: current path). The 'os' input specifies 
% the type of machine (os = 'win' for Windows and os = 'unix' for mac and 
% linux). The output is ... :
%   - 


    % Set default parameters to the current folder path and windows os
    if nargin<2
        imPath = pwd;
        os = 'win';
    end
    if nargin<1
        imPath = pwd;
    end
    
    % Adding the tools folder to the path 
    if strcmp('win',os)==1
        addpath 'tools\';
    elseif strcmp('unix',os)==1
        addpath 'tools/';
    end
    
    % Loading the images files from the imPath
    [imFiles,imPath] = loadImFiles(imPath,os);
    
    if length(imFiles)>0
        % Output initialization
        meanRough = zeros(length(imFiles),1);
        dose      = zeros(length(imFiles),1);

        % Loop over all the images of imPath
        for kIm = 1:length(imFiles)

            % Loading the current image
            imName = imFiles(kIm).name;
            strFileName = strcat(imPath,imName);
            disp(strFileName);
            im = imread(strFileName);

            % Extracting the dose from the file name
            dose(kIm) = str2double(strFileName(end-8:end-6));

            % Crop a part of the background
            im = imCrop(im);

            % High frequency Noise filtering
            im = wiener2(im);

            % Converting the image in black and white for the edge detection
            imBW = imThresholding(im);

            % CHecking the contrast quality of the image
            % It is possible that some good image are not considered or the
            % other way round. But it is sort of a trade off. I could find a
            % better method and it is important to avoid image badly
            % thresholded for the line and ellipses fitting ! 
            imContrast = imCheckContrast(imBW);

            %disp(imContrast);

            if imContrast == 1

                % Detecting boundaries
                boundaries = bwboundaries(imBW,4);

                % Clean boudaries from noise 
                boundaries = clearNoiseBoundaries(boundaries);

                % Show image with detected boundaries if need
                %imShowBoundaries(im,boundaries,imName);

                % Interpolation of the edges 
                [intX,intY] = interpolEdges(im);

                % Seperate the beam from the holes 
                beam = boundaries{1};
                holes = boundaries(2:end);

                % Fit the ellipses on the holes using the interpolated edges
                [fittedHoles,holesInt] = fitHoles(holes,intX,intY);

                % Crop the bended part of the beam if needed
                beam = cropBendedPart(beam,fittedHoles);

                % Fit line to the beam edges
                [~,~,edgeIntTop,edgeIntBottom,pTop,pBottom] = fitBeamEdges(beam,fittedHoles,intX,intY); 

                % Computing the mean roughness
                meanRough(kIm) = computeRoughness(edgeIntTop,edgeIntBottom,pTop,pBottom,holesInt,fittedHoles);

            else 
                dose(kIm) = 0;
                meanRough(kIm) = 0;
            end

        end
    
    end
        



end