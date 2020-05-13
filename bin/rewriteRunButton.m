function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Changing the run button into a stop button
set(handles.runButton,'String','Stop Analysis');drawnow;

% Different lines to add and set path
imPath = get(handles.imFolder,'String');
if isempty(imPath)==1
    imPath='.';
end
OSvalue = get(handles.OSbuttongroup.SelectedObject,'String');
if strcmp(OSvalue,'Windows')==1
    OS = 'win';
    handles.OS = OS;
elseif strcmp(OSvalue,'UNIX')==1
    OS = 'unix';
    handles.OS = OS;
end
guidata(hObject,handles);
write2commandHistory(handles,'Running');

if strcmp('win',OS)==1
    addpath 'tools\';
elseif strcmp('unix',OS)==1
    addpath 'tools/';
end
if exist(imPath,'dir')==7
    [imFiles,imPath] = loadImFiles(imPath,OS);
    handles.imFullPath = imPath;
    guidata(hObject,handles);
else
    write2commandHistory(handles,'The given path does not exist');
end

% Number of images found
nIm = length(imFiles);


% If there is one image or more
if nIm>0 && hitSTOP==0
    
    % Creating the directories if not existing
    if exist(strcat(handles.imFullPath,'cropIm'),'dir')~=7
        mkdir(handles.imFullPath,'cropIm');
    end
    if exist(strcat(handles.imFullPath,'bwIm'),'dir')~=7
        mkdir(handles.imFullPath,'bwIm');
    end
    
    % Creating structure 
    structIm = struct('imContrast','topEdgeRaw','topEdgeInt','topEdgeFit','bottomEdgeRaw',...
                     'bottomEdgeInt','bottomEdgeFit','holesRaw','holesInt',...
                     'holesFit');
    % Variables initialization
%     meanRough = zeros(nIm,1);
%     dose      = zeros(nIm,1);
    
    
    % Loop over the different images
    for i = 1:length(imFiles)
        
        write2commandHistory(handles,sprintf('Image %i of %i : ',i,nIm));
        
        % Loading the current image
        write2commandHistory(handles,' - Loading the image...');
        im = imread(handles.strImFullPath{i});
        write2commandHistory(handles,' - Image Loaded');
        % Update the images list in the popup menu
        
        if i~=1
            listImNames = cellstr(get(handles.imSelPopUpMenu,'String'));
            listImFullPath = cellstr(handles.listImFullPath);
            listImNames{end+1} = imFiles(i).name;
            listImFullPath{end+1} = strcat(handles.imFullPath,imFiles(i).name);
        else
            listImNames = imFiles(i).name;
            listImFullPath = strcat(handles.imFullPath,imFiles(i).name);
        end
        
        handles.listImFullPath = listImFullPath;
        handles.listImNames = listImNames;
        set(handles.imSelPopUpMenu,'String',listImNames);
        guidata(hObject,handles);

        % Extracting the dose from the file name
        write2commandHistory(handles,' - Extracting dose...');
        if i~=1
            dose = cat(1,handles.dose,str2double(handles.listImNames{i}(end-8:end-6)));
        else
            dose = str2double(handles.listImNames{i}(end-8:end-6));
        end
        handles.dose = dose;
        guidata(hObject,handles);
        write2commandHistory(handles,' - Dose extracted');
        
        % Cropping the image
        cropped = 0;
        write2commandHistory(handles,' - Image cropping...');
        if strcmp(handles.OS,'win')==1
            imCropName = strcat(handles.imFullPath,'cropIm\',handles.listImNames{i});
        elseif strcmp(handles.OS,'unix')==1
            imCropName = strcat(handles.imFullPath,'cropIm/',handles.listImNames{i});
        end
        % If the image does not exist
        if exist(imCropName,'file')~=2        
            % Crop a part of the background
            im = imCrop(im);
            cropped = 1;
            write2commandHistory(handles,' - Image cropped');
            % High frequency Noise filtering
            write2commandHistory(handles,' - Noise filtering...');
            im = wiener2(im);
            write2commandHistory(handles,' - Noise filtered');
            % Saving the image
            write2commandHistory(handles,' - Saving the cropped image for later use...');
            % Image Name
            imwrite(im,imCropName);
            write2commandHistory(handles,' - Cropped image saved');
        else
            write2commandHistory(handles,' - Cropped image already exists');
        end
        
        % Thresholding 
        write2commandHistory(handles,' - Image thresholding...');
        % Image Name
        if strcmp(handles.OS,'win')==1
            imBWName = strcat(handles.imFullPath,'bwIm\',handles.listImNames{i});
        elseif strcmp(handles.OS,'unix')==1
            imBWName = strcat(handles.imFullPath,'bwIm/',handles.listImNames{i});
        end
        bwTest = 0;
        if exist(imBWName,'file')~=2
            
            % Loading the current image
            if strcmp(handles.OS,'win')==1 && cropped==0;
                im = imread(strcat(handles.imFullPath,'cropIm\',handles.listImNames{i}));
            elseif strcmp(handles.OS,'unix')==1  && cropped==0;
                im = imread(strcat(handles.imFullPath,'cropIm/',handles.listImNames{i}));
            end

            %Converting the image in black and white for the edge detection
            imBW = imThresholding(im);
            bwTest = 1;
            write2commandHistory(handles,' - Image thresholded');
            % Saving images
            write2commandHistory(handles,' - Saving thresholded image...');
            if strcmp(handles.OS,'win')==1
                imwrite(imBW,strcat(handles.imFullPath,'bwIm\',handles.listImNames{i}));
            elseif strcmp(handles.OS,'unix')==1
                imwrite(imBW,strcat(handles.imFullPath,'bwIm/',handles.listImNames{i}));
            end
            write2commandHistory(handles,' - Image saved');
        end
        
        % Computing the fitting the edges
        
        % Checking if the data were already computed in the past
        if exist(strcat(handles.imFullPath,'imData.mat'),'file') ~= 2
            % OS system check and if the variable already exist
            if strcmp(handles.OS,'win')==1
                if bwTest == 0
                    imBW = imread(strcat(handles.imFullPath,'\bwIm\',handles.strImName{i}));
                end
                if cropped == 0
                    im = imread(strcat(handles.imFullPath,'\cropIm\',handles.strImName{i}));
                end
            elseif strcmp(handles.OS,'unix')==1
                if bwTest == 0
                    imBW = imread(strcat(handles.imFullPath,'/bwIm/',handles.strImName{i}));
                end
                if cropped == 0
                	im = imread(strcat(handles.imFullPath,'/cropIm/',handles.strImName{i}));
                end
            end
            
            % Checking image contrast
            write2commandHistory(handles,' - Checking image contrast...');
            imContrast = imCheckContrast(imBW);
            if imContrast == 1 
                write2commandHistory(handles,' - Image contrast is good');
            else
                write2commandHistory(handles,' - Image contrast is bad');
            end
            
            % Analyse if the contrast is ok
            if imContrast == 1
                % Detecting boundaries
                write2commandHistory(handles,' - Detecting image boundries...');
                boundaries = bwboundaries(imBW,4);
                write2commandHistory(handles,' - Boundries detected')
                
                % Clean boudaries from noise 
                write2commandHistory(handles,' - Cleaning boundries of noise...');
                boundaries = clearNoiseBoundaries(boundaries);
                write2commandHistory(handles,' - Boundaries cleaned');
                
                % Interpolation of the edges 
                write2commandHistory(handles,' - Interpolating the edges...');
                [intX,intY] = interpolEdges(im);
                write2commandHistory(handles,' - Edges interpolated');

                % Seperate the beam from the holes 
                beam = boundaries{1};
                holes = boundaries(2:end);

                % Fit the ellipses on the holes using the interpolated edges
                write2commandHistory(handles,' - Fitting the holes...');
                [fittedHoles,holesInt] = fitHoles(holes,intX,intY);
                write2commandHistory(handles,' - Holes fitted');
                
                % Crop the bended part of the beam if needed
                beam = cropBendedPart(beam,fittedHoles);

                % Fit line to the beam edges
                write2commandHistory(handles,' - Fitting the beam...');
                [edgeTop,edgeBottom,edgeIntTop,edgeIntBottom,pTop,pBottom] = fitBeamEdges(beam,fittedHoles,intX,intY);
                write2commandHistory(handles,' - Beam fitted');
                
                % Computing the fitted data
                edgeTopFit = edgeTop;
                edgeTopFit(:,1) = polyval(pTop,edgeTop(:,2));
                edgeTopFit(:,2) = edgeTop(:,2);
                edgeBottomFit = edgeBottom;
                edgeBottomFit(:,1) = polyval(pBottom,edgeBottom(:,2));
                edgeBottomFit(:,2) = edgeBottom(:,2);
                holesFit = holes;
                for k = 1:length(holes)
                    holesFit{k} = computeFittedEllipse(fittedHoles{k},holesInt{k}(:,2),holesInt{k}(:,1));
                end
                structIm.imContrast = 1;
                structIm.topEdgeRaw = edgeTop;
                structIm.topEdgeInt = edgeIntTop;
                structIm.topEdgeFit = edgeTopFit;
                structIm.bottomEdgeRaw = edgeBottom;
                structIm.bottomEdgeInt = edgeIntBottom;
                structIm.bottomEdgeFit = edgeBottomFit;
                structIm.holesRaw = holes;
                structIm.holesInt = holesInt;
                structIm.holesFit = holesFit;
                
                % Computing the mean roughness
                meanRough = computeRoughness(edgeIntTop,edgeIntBottom,pTop,pBottom,holesInt,fittedHoles);
                
            else % The contrast is not good
                structIm.imContrast = 0;
                structIm.topEdgeRaw = zeros(2,1);
                structIm.topEdgeInt = zeros(2,1);
                structIm.topEdgeFit = zeros(2,1);
                structIm.bottomEdgeRaw = zeros(2,1);
                structIm.bottomEdgeInt = zeros(2,1);
                structIm.bottomEdgeFit = zeros(2,1);
                structIm.holesRaw = zeros(2,1);
                structIm.holesInt = zeros(2,1);
                structIm.holesFit = zeros(2,1);

                handles.dose(i) = 0;
                meanRough = 0;
            end
            
            if i ~= 1
                imData = structIm;
                handles.meanRough = meanRough;
                vecMeanRough = meanRough;
            else
                imData = handles.imData;
                imData{end+1} = structIm;
                bin = handles.meanRough;
                handles.meanRough = cat(1,bin,meanRough);
                vecMeanRough = cat(1,bin,meanRough);
                vecDose = handles.dose;
            end
            guidata(hObject,handles);
            
            % Saving imData
            write2commandHistory(handles,' - Saving data...');
            save(strcat(handles.imFullPath,'imData.mat'),'imData','vecDose','vecMeanRough');
            write2commandHistory(handles,' - Data saved');
        else % Data already analyzed
            write2commandHistory(' - Data already exist : loading them...');
            load(strcat(handles.imFullPath,'imData.mat'));
            handles.dose = vecDose;
            handles.meanRough = vecMeanRough;
            guidata(hObject,handles);
        end
        
    end 
    % Plotting Roughness vs Dose
    axes(handles.imPlot);
    sc = scatter(handles.dose(handles.dose~=0),handles.meanRough(handles.dose~=0),'x');
    xlabel('Dose');
    ylabel('Mean Roughness');
    grid on;
    handles.sc = sc;
    guidata(hObject,handles);
    highlightPlot(handles);
    % Displaying image
    displayImage(handles);

else % No tif images in the directory
    write2commandHistory(handles,'No tif image files in the specified folder');
 
end
set(handles.runButton,'String','Run Analysis');drawnow;

