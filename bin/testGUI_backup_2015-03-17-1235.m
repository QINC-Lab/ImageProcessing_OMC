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

% Last Modified by GUIDE v2.5 16-Mar-2015 15:28:02

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
set(handles.runButton,'String','Stop Analysis');drawnow;

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
nIm = length(imFiles);
if nIm>0
    % Creating the images path
    strImFullPath = cell(length(imFiles),1);
    strImName = cell(length(imFiles),1);
    for i = 1:length(imFiles)
        strImFullPath{i} = strcat(handles.imFullPath,imFiles(i).name);
        strImName{i} = imFiles(i).name;
    end
    handles.strImFullPath = strImFullPath;
    handles.strImName = strImName;
    % Putting the images in the popup menu
    set(handles.imSelPopUpMenu,'String',strImName);
    guidata(hObject,handles);

    % Creating the directories 
    if exist(strcat(handles.imFullPath,'cropIm'),'dir')~=7
        mkdir(handles.imFullPath,'cropIm');
    end
    if exist(strcat(handles.imFullPath,'bwIm'),'dir')~=7
        mkdir(handles.imFullPath,'bwIm');
    end
    % Output initialization
    meanRough = zeros(nIm,1);
    dose      = zeros(nIm,1);
    
    % Extracting the dose from the file name
    for i = 1:nIm
        write2commandHistory(handles,sprintf('Extracting dose : image %i of %i',i,nIm));
        %set(handles.statusText,'ForegroundColor','blue');
        %set(handles.statusText,'String',sprintf('Extracting dose : image %i of %i',i,nIm));drawnow;
        
        % Loading the current image
        dose(i) = str2double(handles.strImFullPath{i}(end-8:end-6));
        
    end
        
    % Cropping the images
    for i = 1:nIm
        write2commandHistory(handles,sprintf('Cropping and noise filtering : image %i of %i',i,nIm));
        %set(handles.statusText,'ForegroundColor','blue');
        %set(handles.statusText,'String',sprintf('Cropping and noise filtering : image %i of %i',i,nIm));drawnow;
        
        % Image Name
        if strcmp(handles.OS,'win')==1
            imCropName = strcat(handles.imFullPath,'cropIm\',handles.strImName{i});
        elseif strcmp(handles.OS,'unix')==1
            imCropName = strcat(handles.imFullPath,'cropIm/',handles.strImName{i});
        end
        
        % If the image does not exist
        if exist(imCropName,'file')~=2
            % Loading the current image
            im = imread(handles.strImFullPath{i});
            % Crop a part of the background
            im = imCrop(im);

            % High frequency Noise filtering
            im = wiener2(im);

            imwrite(im,imCropName);
        end
        
    end
    
    % Thresholding to black and white for the edge detection
    for i = 1:nIm
        write2commandHistory(handles,sprintf('Thresholding to Black/White : image %i of %i',i,nIm));
        %set(handles.statusText,'ForegroundColor','blue');
        %set(handles.statusText,'String',sprintf('Thresholding to Black/White : image %i of %i',i,nIm));drawnow;
        % Image Name
        if strcmp(handles.OS,'win')==1
            imBWName = strcat(handles.imFullPath,'bwIm\',handles.strImName{i});
        elseif strcmp(handles.OS,'unix')==1
            imBWName = strcat(handles.imFullPath,'bwIm/',handles.strImName{i});
        end
        
        if exist(imBWName,'file')~=2
        
            % Loading the current image
            if strcmp(handles.OS,'win')==1
                im = imread(strcat(handles.imFullPath,'cropIm\',handles.strImName{i}));
            elseif strcmp(handles.OS,'unix')==1
                im = imread(strcat(handles.imFullPath,'cropIm/',handles.strImName{i}));
            end

            %Converting the image in black and white for the edge detection
            imBW = imThresholding(im);
            % Saving images
            if strcmp(handles.OS,'win')==1
                imwrite(imBW,strcat(handles.imFullPath,'bwIm\',handles.strImName{i}));
            elseif strcmp(handles.OS,'unix')==1
                imwrite(imBW,strcat(handles.imFullPath,'bwIm/',handles.strImName{i}));
            end
        end
    end
    
    % Creating structure 
    structIm = struct('imContrast','topEdgeRaw','topEdgeInt','topEdgeFit','bottomEdgeRaw',...
                     'bottomEdgeInt','bottomEdgeFit','holesRaw','holesInt',...
                     'holesFit');
    
    
    if exist(strcat(handles.imFullPath,'imData.mat'),'file') ~= 2
        % Boudaries detection
        imData = cell(nIm,1);
        for i = 1:nIm

            write2commandHistory(handles,sprintf('Boudaries detection, interpolation and fitting : image %i of %i',i,nIm));
            %set(handles.statusText,'ForegroundColor','blue');
            %set(handles.statusText,'String',sprintf('Boudaries detection, interpolation and fitting : image %i of %i',i,nIm));drawnow;

            % Loading the current image
            if strcmp(handles.OS,'win')==1
                imBW = imread(strcat(handles.imFullPath,'\bwIm\',handles.strImName{i}));
                im = imread(strcat(handles.imFullPath,'\cropIm\',handles.strImName{i}));
            elseif strcmp(handles.OS,'unix')==1
                imBW = imread(strcat(handles.imFullPath,'/bwIm/',handles.strImName{i}));
                im = imread(strcat(handles.imFullPath,'/cropIm/',handles.strImName{i}));
            end
            imContrast = imCheckContrast(imBW);

            if imContrast == 1
               % Detecting boundaries
                boundaries = bwboundaries(imBW,4);

                % Clean boudaries from noise 
                boundaries = clearNoiseBoundaries(boundaries);

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
                [edgeTop,edgeBottom,edgeIntTop,edgeIntBottom,pTop,pBottom] = fitBeamEdges(beam,fittedHoles,intX,intY);

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
                meanRough(i) = computeRoughness(edgeIntTop,edgeIntBottom,pTop,pBottom,holesInt,fittedHoles);

            else
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

                dose(i) = 0;
                meanRough(i) = 0;
            end

            imData{i} = structIm;
        end
    
        % Saving imData
        save(strcat(handles.imFullPath,'imData.mat'),'imData');
        
    end
    
    handles.dose = dose;
    handles.meanRough = meanRough;
    guidata(hObject,handles);
    
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

else
    write2commandHistory(handles,'No tif image files in the specified folder');
    %set(handles.statusText,'String','No tif image files in the specified folder');
    %set(handles.statusText,'ForegroundColor','red');
end
set(handles.runButton,'String','Run Analysis');drawnow;


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

% Plotting Roughness vs Dose
highlightPlot(handles);



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
p = get(handles.imPlot,'CurrentPoint');
xClic = p(1,1);
yClic = p(1,2);
d2Clic = hypot(xClic-handles.dose,yClic-handles.meanRough);
ind = round(mean(find(d2Clic==min(d2Clic(:)))));
set(handles.imSelPopUpMenu,'Value',ind);
displayImage(handles);
highlightPlot(handles);


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
