function varargout = testGUI(varargin)
% TESTGUI MATLAB code for testGUI.fig
%      TESTGUI, by itself, creates a new TESTGUI or raises the existing
%      singleton*.
%
%      H = TESTGUI returns the handle to a new TESTGUI or the handle to
%      the existing singleton*.
%
%      TESTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTGUI.M with the given input arguments.
%
%      TESTGUI('Property','Value',...) creates a new TESTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testGUI

% Last Modified by GUIDE v2.5 18-Mar-2015 10:57:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @testGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before testGUI is made visible.
function testGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testGUI (see VARARGIN)

% Choose default command line output for testGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes testGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function imFolder_Callback(hObject, eventdata, handles)
% hObject    handle to imFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imFolder as text
%        str2double(get(hObject,'String')) returns contents of imFolder as a double


% --- Executes during object creation, after setting all properties.
function imFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset command history
set(handles.commandHistory,'String','');
set(handles.imSelPopUpMenu, 'value', 1);

% Changing the run button into a stop button
if get(hObject,'Value')==1
    set(handles.runButton,'String','Stop');drawnow;

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
    
    if strcmp('win',OS)==1
        addpath 'tools\';
    elseif strcmp('unix',OS)==1
        addpath 'tools/';
    end
    
    write2commandHistory(handles,'Running');

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
    if nIm>0 

        % Creating the directories if not existing
        if exist(strcat(handles.imFullPath,'cropIm'),'dir')~=7
            mkdir(handles.imFullPath,'cropIm');
        end
        if exist(strcat(handles.imFullPath,'bwIm'),'dir')~=7
            mkdir(handles.imFullPath,'bwIm');
        end

        % Creating structure 
        structIm = struct();


        % Loop over the different images
        for i = 1:length(imFiles)

            write2commandHistory(handles,sprintf('Image %i of %i : ',i,nIm));

            if i~=1
                listImNames = get(handles.imSelPopUpMenu,'String');
                listImFullPath = handles.listImFullPath;
                listImNames{end+1} = imFiles(i).name;
                listImFullPath{end+1} = strcat(handles.imFullPath,imFiles(i).name);
            else
                listImNames = cell(0);
                listImNames{1} = imFiles(i).name;
                listImFullPath = cell(0);
                listImFullPath{1} = strcat(handles.imFullPath,imFiles(i).name);
            end

            handles.listImFullPath = listImFullPath;
            handles.listImNames = listImNames;
            set(handles.imSelPopUpMenu,'String',listImNames);
            guidata(hObject,handles);

            % Checking if the image file was already analysed 
            imProcessed = 0;
            if exist(strcat(handles.imFullPath,'imData.mat'),'file') == 2
                load(strcat(handles.imFullPath,'imData.mat'));
                imDataExist = 1;
                for j = 1 : length(imData)
                    if strcmp(imData{j}.imName,handles.listImNames{i})==1
                        imProcessed =1;
                    end
                end

            else
                imDataExist = 0;
            end



            if imProcessed==0
                % Loading the current image
                write2commandHistory(handles,' - Loading the image...');
                im = imread(handles.listImFullPath{i});
                write2commandHistory(handles,' - Image Loaded');

                % Extracting the dose from the file name
                write2commandHistory(handles,' - Extracting dose...');
%                 if i~=1
%                     dose = cat(1,handles.dose,str2double(handles.listImNames{i}(end-8:end-6)));
%                     meanRough = cat(1,handles.meanRough,0);
%                 else
                    dose = str2double(handles.listImNames{i}(end-8:end-6));
%                     meanRough = 0;
%                 end
%                 handles.dose = dose;
%                 handles.meanRough = meanRough;
                guidata(hObject,handles);
                write2commandHistory(handles,' - Dose extracted');
                
                % Getting the image scale
                write2commandHistory(handles,' - Extracting Image Scale');
                scl = getScale(handles.listImFullPath{i});
                handles.scl = scl;
                guidata(hObject,handles);
                write2commandHistory(handles,' - Extracting Imaqge Scale');
                
                
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

                % OS system check and if the variable already exist
                if strcmp(handles.OS,'win')==1
                    if bwTest == 0
                        imBW = imread(strcat(handles.imFullPath,'\bwIm\',handles.listImNames{i}));
                    end
                    if cropped == 0
                        im = imread(strcat(handles.imFullPath,'\cropIm\',handles.listImNames{i}));
                    end
                elseif strcmp(handles.OS,'unix')==1
                    if bwTest == 0
                        imBW = imread(strcat(handles.imFullPath,'/bwIm/',handles.listImNames{i}));
                    end
                    if cropped == 0
                        im = imread(strcat(handles.imFullPath,'/cropIm/',handles.listImNames{i}));
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
%                     holesFit = holes;
%                     for k = 1:length(holes)
%                         holesFit{k} = computeFittedEllipse(fittedHoles{k},holesInt{k}(:,2),holesInt{k}(:,1));
%                     end

                    % Computing the mean roughness
                    write2commandHistory(handles,' - Computing the roughness...');
                    [meanRough,holesFit] = computeRoughness(edgeIntTop,edgeIntBottom,pTop,pBottom,holesInt,fittedHoles,handles.scl);
                    write2commandHistory(handles,' - Roughness computed');
                    
                    structIm.imName = handles.listImNames{i};
                    structIm.imContrast = 1;
                    structIm.imDose = dose;
                    structIm.imMeanRough = meanRough;
                    structIm.topEdgeRaw = edgeTop;
                    structIm.topEdgeInt = edgeIntTop;
                    structIm.topEdgeFit = edgeTopFit;
                    structIm.bottomEdgeRaw = edgeBottom;
                    structIm.bottomEdgeInt = edgeIntBottom;
                    structIm.bottomEdgeFit = edgeBottomFit;
                    structIm.holesRaw = holes;
                    structIm.holesInt = holesInt;
                    structIm.holesFit = holesFit;
                    structIm.ellipses = fittedHoles;
                    structIm.imScale    = scl;

%                     handles.meanRough(i) = meanRough;


                else % The contrast is not good
                    structIm.imName = handles.listImNames{i};
                    structIm.imContrast = 0;
                    structIm.imDose = 0;
                    structIm.imMeanRough = 0;
                    structIm.topEdgeRaw = zeros(2,1);
                    structIm.topEdgeInt = zeros(2,1);
                    structIm.topEdgeFit = zeros(2,1);
                    structIm.bottomEdgeRaw = zeros(2,1);
                    structIm.bottomEdgeInt = zeros(2,1);
                    structIm.bottomEdgeFit = zeros(2,1);
                    structIm.holesRaw = zeros(2,1);
                    structIm.holesInt = zeros(2,1);
                    structIm.holesFit = zeros(2,1);
                    structIm.ellipses = 0;
                    structIm.imScale    = scl;
%                     handles.dose(i) = 0;
                end

                if imDataExist == 1
                    imData{end+1} = structIm;
                else
                    imData = cell(0);
                    imData{1} = structIm;
                end



                % Saving imData
                write2commandHistory(handles,' - Saving data...');
                save(strcat(handles.imFullPath,'imData.mat'),'imData');
                write2commandHistory(handles,' - Data saved');
            else % Data already analyzed
                write2commandHistory(handles,' - Data already processed');
%                 imDataMat = cell2mat(imData);
%                 handles.dose(i) = imData{strncmp(listImNames{i},{imDataMat.imName},1000)}.imDose;
%                 handles.meanRough(i) = imData{strncmp(listImNames{i},{imDataMat.imName},1000)}.imMeanRough;
            end
            guidata(hObject,handles);drawnow;

            if get(handles.runButton,'Value') == 0
                set(handles.runButton,'String','Run Analysis');drawnow;
                break;
            end
        end

    drawPlot(hObject,handles);
    % Displaying image
    displayImage(handles);

    else % No tif images in the directory
        write2commandHistory(handles,'No tif image files in the specified folder');

    end
    set(handles.runButton,'String','Run Analysis');drawnow;
    set(handles.runButton,'Value',0);
    guidata(hObject,handles);
else
    set(handles.runButton,'String','Run Analysis');drawnow;
    drawPlot(hObject,handles);
    % Displaying image
    displayImage(handles);
end




% --- Executes on selection change in imSelPopUpMenu.
function imSelPopUpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to imSelPopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imSelPopUpMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imSelPopUpMenu
write2commandHistory(handles,'Image changed');
%set(handles.statusText,'ForegroundColor','blue');
%set(handles.statusText,'String','Image changed');drawnow;
displayImage(handles);
drawPlot(hObject,handles);
% Plotting Roughness vs Dose
%highlightPlot(handles);



% --- Executes during object creation, after setting all properties.
function imSelPopUpMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imSelPopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in beamRawBox.
function beamRawBox_Callback(hObject, eventdata, handles)
% hObject    handle to beamRawBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImage(handles);


% Hint: get(hObject,'Value') returns toggle state of beamRawBox


% --- Executes on button press in holesRawBox.
function holesRawBox_Callback(hObject, eventdata, handles)
% hObject    handle to holesRawBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImage(handles);
% Hint: get(hObject,'Value') returns toggle state of holesRawBox


% --- Executes on button press in beamIntBox.
function beamIntBox_Callback(hObject, eventdata, handles)
% hObject    handle to beamIntBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImage(handles);
% Hint: get(hObject,'Value') returns toggle state of beamIntBox


% --- Executes on button press in holesIntBox.
function holesIntBox_Callback(hObject, eventdata, handles)
% hObject    handle to holesIntBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImage(handles);
% Hint: get(hObject,'Value') returns toggle state of holesIntBox

 
% --- Executes on button press in beamFitBox.
function beamFitBox_Callback(hObject, eventdata, handles)
% hObject    handle to beamFitBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImage(handles);
% Hint: get(hObject,'Value') returns toggle state of beamFitBox


% --- Executes on button press in holesFitBox.
function holesFitBox_Callback(hObject, eventdata, handles)
% hObject    handle to holesFitBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImage(handles);
% Hint: get(hObject,'Value') returns toggle state of holesFitBox


% --- Executes when selected object is changed in imTypeButtongroup.
function imTypeButtongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in imTypeButtongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImage(handles);


% --- Executes on mouse press over axes background.
function imPlot_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to imPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pos = get(handles.imPlot,'CurrentPoint');
h = waitbar(0,'Loading...');
xClic = pos(1,1);
yClic = pos(1,2);
plt = get(handles.plotShownListbox,'String');
load(strcat(handles.imFullPath,'imData.mat'));
imDataMat = cell2mat(imData);
switch plt{1}
    case 'Dose - Mean Roughness'
        dose = [imDataMat.imDose];
        scl = [imDataMat.imScale];
        meanRough = [imDataMat.imMeanRough];
        %d2Clic = hypot((xClic-dose)/max(dose(:)),(yClic-meanRough./scl)/max(meanRough(:)./scl));
        d2Clic = hypot((xClic-dose)/mean(max(dose(:))),(yClic-meanRough)/mean(max(meanRough(:))));
        ind = round(mean(find(d2Clic==min(d2Clic(:)))));
        set(handles.imSelPopUpMenu,'Value',ind);
end

displayImage(handles);
highlightPlot(handles);
close(h);


function commandHistory_Callback(hObject, eventdata, handles)
% hObject    handle to commandHistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of commandHistory as text
%        str2double(get(hObject,'String')) returns contents of commandHistory as a double


% --- Executes during object creation, after setting all properties.
function commandHistory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to commandHistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stopButton,'Value',1);drawnow;
guidata(hObject,handles);drawnow;
% set(handles.stopButton,'Enable','Off');drawnow;
% guidata(hObject,handles);drawnow;


% --- Executes on button press in discardButton.
function discardButton_Callback(hObject, eventdata, handles)
% hObject    handle to discardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
confirm = questdlg('You are about to discard this point from the analysis. Do you want to continue?',...
                   'Confirmation of point suppression','Yes, Momentarily','Yes, Permanently','No','No');
switch confirm
    case 'No'
        
    case {'Yes, Momentarily','Yes, Permanently'}
        ind = get(handles.imSelPopUpMenu,'Value');
        handles.dose(ind) = 0;
        handles.meanRough(ind) = 0;
        
        indMax = length(handles.dose);
        if ind<indMax-1
            set(handles.imSelPopUpMenu,'Value',ind+1);
        else
            set(handles.imSelPopUpMenu,'Value',ind-1);
        end

        if strcmp(confirm,'Yes, Permanently')
            load(strcat(handles.imFullPath,'imData.mat'));
            imDataMat = cell2mat(imData);
            imData{strncmp(handles.listImNames{ind},{imDataMat.imName},1000)}.imDose = 0;
            imData{strncmp(handles.listImNames{ind},{imDataMat.imName},1000)}.imMeanRough = 0;
            save(strcat(handles.imFullPath,'imData.mat'),'imData');
        end
        drawPlot(hObject,handles);
        displayImage(handles);
end


% --- Executes on button press in imPlotSaveButton.
function imPlotSaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to imPlotSaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(0,'DefaultFigureVisible','off')
ax = handles.imPlot;
tempFig = figure;
tempAx = gca;
copyobj(ax.Children,tempAx);
tempXLab = get(ax,'XLabel');
tempYLab = get(ax,'YLabel');
tempXGrid = get(ax,'XGrid');
tempYGrid = get(ax,'YGrid');
set(tempAx,'XLabel',tempXLab);
set(tempAx,'YLabel',tempYLab);
set(tempAx,'XGrid',tempXGrid);
set(tempAx,'YGrid',tempYGrid);

[imPlotName,imPlotPath] = uiputfile({'*.fig';'*.jpg';'*.pdf';'*.png';'*.tif'},'Save Image As','.');
saveas(tempFig,strcat(imPlotPath,imPlotName));
clear tempFig;
set(0,'DefaultFigureVisible','on')

% --- Executes on button press in imSaveButton.
function imSaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to imSaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(0,'DefaultFigureVisible','off')
ax = handles.im;
tempFig = figure;
tempAx = gca;
copyobj(ax.Children,tempAx);
colormap(tempAx,colormap(ax));
set(tempAx,'Visible','off');
set(ax,'Units','pixels');
set(tempFig,'Units','pixels');
set(tempAx,'Units','pixels');
tempAxCh = tempAx.Children;
for i = 1:length(tempAxCh)
    if strcmp('image',tempAxCh(i).Type)
        [tempYLim,tempXLim] = size(tempAxCh(i).CData);
    end
end
%pos = ax.Position;
set(tempAx,'XLim',[0 tempXLim]);
set(tempAx,'YLim',[0 tempYLim]);
%tempPosA = tempAx.Position;
tempPosF = tempFig.Position;
tempPosA = [0,0,tempXLim,tempYLim];
tempPosF = [tempPosF(1),tempPosF(2),tempXLim,tempYLim];
set(tempFig,'Position',tempPosF);
set(tempAx,'Position',tempPosA);
set(tempFig,'Units','centimeters');
set(tempFig,'PaperUnits','centimeters');
tempPosF = get(tempFig,'Position');
set(tempFig,'PaperPosition',[0,0,tempPosF(3),tempPosF(4)]);
set(tempFig,'PaperSize',[tempPosF(3),tempPosF(4)]);
[imName,imPath] = uiputfile({'*.fig';'*.jpg';'*.pdf';'*.png';'*.tif'},'Save Image As','.');
saveas(tempFig,strcat(imPath,imName));
clear tempFig;
set(0,'DefaultFigureVisible','on')


% --- Executes on selection change in plotAvailableListbox.
function plotAvailableListbox_Callback(hObject, eventdata, handles)
% hObject    handle to plotAvailableListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotAvailableListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotAvailableListbox


% --- Executes during object creation, after setting all properties.
function plotAvailableListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotAvailableListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Initialization of the available plot list box
pltList = cell(0);
pltList{1} = 'Dose - Mean Roughness';
pltList{2} = 'Holes - Long Axis';
pltList{3} = 'Holes - Short Axis';
set(hObject,'String',pltList);


% --- Executes on selection change in plotShownListbox.
function plotShownListbox_Callback(hObject, eventdata, handles)
% hObject    handle to plotShownListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotShownListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotShownListbox


% --- Executes during object creation, after setting all properties.
function plotShownListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotShownListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addPlotButton.
function addPlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to addPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel = get(handles.plotAvailableListbox,'Value');
pltList = get(handles.plotAvailableListbox,'String');
pltShown = get(handles.plotShownListbox,'String');
if sum(strncmp(pltList{sel},pltShown,400)) == 0
    pltShown{end+1} = pltList{sel};
    set(handles.plotShownListbox,'String',pltShown);
end
drawPlot(hObject,handles);



% --- Executes on button press in rmPlotButton.
function rmPlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to rmPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel = get(handles.plotShownListbox,'Value');
pltShown = get(handles.plotShownListbox,'String');
ind = ones(size(pltShown));
ind(sel) = 0;
pltShownNew = pltShown(logical(ind));
if sel>1
    set(handles.plotShownListbox,'Value',sel-1);
end
set(handles.plotShownListbox,'String',pltShownNew);
drawPlot(hObject,handles);



% --- Executes on button press in levelUpPlotButton.
function levelUpPlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to levelUpPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pltList = get(handles.plotShownListbox,'String');
sel = get(handles.plotShownListbox,'Value');
if length(pltList)>1 && sel>1
    ind = linspace(1,length(pltList),length(pltList));
    ind(sel-1) = ind(sel);
    ind(sel) = ind(sel)-1;
    pltListNew = pltList(ind);
    set(handles.plotShownListbox,'String',pltListNew);
    set(handles.plotShownListbox,'Value',sel-1);
end
drawPlot(hObject,handles);


% --- Executes on button press in levelDownPlotButton.
function levelDownPlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to levelDownPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pltList = get(handles.plotShownListbox,'String');
sel = get(handles.plotShownListbox,'Value');
if length(pltList)>1 && sel<length(pltList)
    ind = linspace(1,length(pltList),length(pltList));
    ind(sel+1) = ind(sel);
    ind(sel) = ind(sel)+1;
    pltListNew = pltList(ind);
    set(handles.plotShownListbox,'String',pltListNew);
    set(handles.plotShownListbox,'Value',sel+1);
end
drawPlot(hObject,handles);
