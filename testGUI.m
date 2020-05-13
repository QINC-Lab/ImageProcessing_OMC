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

% Last Modified by GUIDE v2.5 27-Jan-2017 14:38:11

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

% Initialization of the available plot list box
pltList = cell(0);

% Loading masks file or not
masksTest = get(handles.loadMasksCheckbox,'Value');

switch masksTest
    case 0
        pltList{1} = 'Holes - Long Axis';
        pltList{2} = 'Holes - Short Axis';
        pltList{3} = 'Holes - Holes Interval';
    case 1
        pltList{1} = 'p : Mask - Measured';
        pltList{2} = 'hx : Mask - Measured';
        pltList{3} = 'hy : Mask - Measured';
        pltList{4} = 'Beam Width : Mask - Measured';
        pltList{5} = 'Holes - Long Axis';
        pltList{6} = 'Holes - Short Axis';
        pltList{7} = 'Holes - Holes Interval';
        pltList{8} = 'All length : Mask - Measured';
        pltList{9} = 'All length : Curvature - Measured';
end

% pltList{8} = 'Length - Length Difference';
set(handles.plotAvailableListbox,'String',pltList);


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
    if strcmp(OSvalue,'Win')==1
        OS = 'win';
        handles.OS = OS;
        fileSep = '\';
    elseif strcmp(OSvalue,'UNIX')==1
        OS = 'unix';
        handles.OS = OS;
        fileSep = '/';
    end
    guidata(hObject,handles);
    
    addpath(strcat('tools',fileSep));
    
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
                
%                 % Getting the image scale
%                 write2commandHistory(handles,' - Extracting Image Scale');
%                 scl = getScale(handles.listImFullPath{i});
%                 write2commandHistory(handles,' - Extracting Image Scale');
                
                % Getting the image sample number (letter in fact)
                write2commandHistory(handles,' - Extracting Image Sample');
                sampleLet = handles.listImFullPath{i}(end-6);
                switch sampleLet 
                    case 'A'
                        sample = 1;
                    case 'B'
                        sample = 2;
                    case 'C'
                        sample = 3;
                    case 'D'
                        sample = 4;
                    case 'E'
                        sample = 5;
                    case 'F'
                        sample = 6;
                    case 'G'
                        sample = 7;
                    case 'H'
                        sample = 8;
                    otherwise
                        sample = 0;
                end
                write2commandHistory(handles,' - Extracting Image Sample');
                
                % Getting the image chip number
                write2commandHistory(handles,' - Extracting Image Chip');
                chip = str2double(handles.listImFullPath{i}(end-7));
                write2commandHistory(handles,' - Extracting Image Chip');
                
                % Getting the image photonic crystal number
                write2commandHistory(handles,' - Extracting Image PC');
                phCry = str2double(handles.listImFullPath{i}(end-5:end-4));
                write2commandHistory(handles,' - Extracting Image PC');
                
                % Extracting the dose from the file name
                write2commandHistory(handles,' - Extracting dose...');
                %%%%%%%%%%%%%% CHANGE HERE %%%%%%%%%% use the mask file
                dose = str2double(handles.listImNames{i}(end-11:end-9));
                write2commandHistory(handles,' - Dose extracted');

                % Cropping the image
                cropped = 0;
                write2commandHistory(handles,' - Image cropping...');
                imCropName = strcat(handles.imFullPath,'cropIm',fileSep,handles.listImNames{i});
                ScaleSEM= getScaleSEM(handles.listImFullPath{i});
                % If the image does not exist
                if exist(imCropName,'file')~=2        
                    % Crop a part of the background
                    [im,HV] = imCrop(im,ScaleSEM);
                    cropped = 1;
                    write2commandHistory(handles,' - Image cropped');
					write2commandHistory(handles,[' - Image Horizontal?',num2str(HV)]);

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
                imBWName = strcat(handles.imFullPath,'bwIm',fileSep,handles.listImNames{i});

                bwTest = 0;
                if exist(imBWName,'file')~=2

                    % Loading the current image
                    im = imread(strcat(handles.imFullPath,'cropIm',fileSep,handles.listImNames{i}));
                        
                    %Converting the image in black and white for the edge detection
                    imBW = imThresholding(im);
                    bwTest = 1;
                    write2commandHistory(handles,' - Image thresholded');
                    % Saving images
                    write2commandHistory(handles,' - Saving thresholded image...');
                    imwrite(imBW,strcat(handles.imFullPath,'bwIm',fileSep,handles.listImNames{i}));
                    write2commandHistory(handles,' - Image saved');
                end

                % Computing the fitting the edges

                % OS system check and if the variable already exist
                if bwTest == 0
                    imBW = imread(strcat(handles.imFullPath,fileSep,'bwIm',fileSep,handles.listImNames{i}));
                end
                if cropped == 0
                    im = imread(strcat(handles.imFullPath,fileSep,'cropIm',fileSep,handles.listImNames{i}));
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
                    
                    % Getting the image scale
                    write2commandHistory(handles,' - Extracting Image Scale');
					if HV==1;
						% if The beam is horizontal;
				         scl = getScale2(fittedHoles,handles.listImFullPath{i});
					else scl=ScaleSEM;
					end
					write2commandHistory(handles,' - Image Scale Extracted');

                    % Computing the mean roughness
                    write2commandHistory(handles,' - Computing the roughness...');
                    [meanRough,holesFit] = computeRoughness(edgeIntTop,edgeIntBottom,pTop,pBottom,holesInt,fittedHoles,scl);
                    write2commandHistory(handles,' - Roughness computed');
                    
                    % Computing the beam width
                    x1 = edgeTopFit(40,2);
                    y1 = edgeTopFit(40,1);
                    x2 = edgeTopFit(end-40,2);
                    y2 = edgeTopFit(end-40,1);
                    dx = abs(x2-x1);
                    dy = abs(y2-y1);                    
                    x3 = x1-dy;
                    y3 = y1+dx;
                    dx = abs(x1-x3);
                    dy = abs(y1-y3);
                    a  = atan(dx/dy);
                    beamWidth = cos(a)*(abs(polyval(pTop,40) - polyval(pBottom,40) ))*scl;
                    
                    structIm.imName = handles.listImNames{i};
                    structIm.imContrast = 1;
                    structIm.imDose = dose;
                    %structIm.imMeanRough = meanRough;
                    structIm.imMeanRough = 0;
                    structIm.topEdgeRaw = edgeTop;
                    structIm.topEdgeInt = edgeIntTop;
                    structIm.topEdgeFit = edgeTopFit;
                    structIm.bottomEdgeRaw = edgeBottom;
                    structIm.bottomEdgeInt = edgeIntBottom;
                    structIm.bottomEdgeFit = edgeBottomFit;
                    structIm.holesRaw  = holes;
                    structIm.holesInt  = holesInt;
                    structIm.holesFit  = holesFit;
                    structIm.ellipses  = fittedHoles;
                    structIm.imScale   = scl;
					structIm.imSEMScale= ScaleSEM;
                    structIm.beamWidth = beamWidth;
                    structIm.imSample  = sample;
                    structIm.imPhCry   = phCry;
                    structIm.imChip = chip;
					structIm.imHorizontal= HV;

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
                    structIm.imScale    = 0;
                    structIm.beamWidth = 0;
                    structIm.imSample = 0;
                    structIm.imPhCry = 0;
                    structIm.imChip = 0;
					structIm.imRotationH= 0;

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
            end
            guidata(hObject,handles);drawnow;

            if get(handles.runButton,'Value') == 0
                set(handles.runButton,'String','Run Analysis');drawnow;
                break;
            end
        end
        
    % Recompute scale 
    %correctImScale(handles);

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
xClic = pos(1,1);
yClic = pos(1,2);

plt = get(handles.plotShownListbox,'String');

ax = handles.imPlot;

switch plt{1}
    case 'Dose - Mean Roughness'
        %h = waitbar(0,'Loading...');
        sc = findobj(ax,'Tag',plt{1});
        dose = sc.XData;
        meanRough = sc.YData;
        d2Clic = hypot((xClic-dose)/mean(max(dose(:))),(yClic-meanRough)/mean(max(meanRough(:))));
        ind = round(mean(find(d2Clic==min(d2Clic(:)))));
        imName = sc.UserData.imName;
        imList = get(handles.imSelPopUpMenu,'String');
        indIm = find(strncmp(imList,imName(ind),1000));
        set(handles.imSelPopUpMenu,'Value',indIm);
        displayImage(handles);
        highlightPlot(handles);
        %close(h);
    case 'Dose - Long Axis'
        %h = waitbar(0,'Loading...');
        sc = findobj(ax,'Tag',plt{1});
        dose = sc.XData;
        lAx = sc.YData;
        imIndList = sc.UserData.indIm;
        holesIndList = sc.UserData.indHole;
        d2Clic = hypot((xClic-dose)/mean(max(dose(:))),(yClic-lAx)/mean(max(lAx(:))));
        indSel = round(mean(find(d2Clic==min(d2Clic(:)))));
        indIm = imIndList(indSel);
        indHole = holesIndList(indSel);
        set(handles.imSelPopUpMenu,'Value',indIm);
        sc.UserData.selHole = indHole;
        displayImage(handles);
        highlightPlot(handles);
        %close(h);
    case 'Dose - Short Axis'
        %h = waitbar(0,'Loading...');
        sc = findobj(ax,'Tag',plt{1});
        dose = sc.XData;
        lAx = sc.YData;
        imIndList = sc.UserData.indIm;
        holesIndList = sc.UserData.indHole;
        d2Clic = hypot((xClic-dose)/mean(max(dose(:))),(yClic-lAx)/mean(max(lAx(:))));
        indSel = round(mean(find(d2Clic==min(d2Clic(:)))));
        indIm = imIndList(indSel);
        indHole = holesIndList(indSel);
        set(handles.imSelPopUpMenu,'Value',indIm);
        sc.UserData.selHole = indHole;
        displayImage(handles);
        highlightPlot(handles);
        %close(h);
    case 'Dose - Beam Width'
        %h = waitbar(0,'Loading...');
        sc = findobj(ax,'Tag',plt{1});
        dose = sc.XData;
        bw = sc.YData;
        imIndList = sc.UserData.indIm;
        d2Clic = hypot((xClic-dose)/mean(max(dose(:))),(yClic-bw)/mean(max(bw(:))));
        indSel = round(mean(find(d2Clic==min(d2Clic(:)))));
        indIm = imIndList(indSel);
        set(handles.imSelPopUpMenu,'Value',indIm);
        displayImage(handles);
        highlightPlot(handles);
        %close(h);
end





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
h = waitbar(0,'Saving plot...');
set(0,'DefaultFigureVisible','off')
resTest = get(handles.residualCheckbox,'Value');

pltList = get(handles.plotShownListbox,'String');

tempFig = figure;
if length(cell2mat(strfind(pltList,'Holes -')))>0    
    if resTest==0
        ax1 = handles.imPlot;
        measData = findobj(ax1,'Tag','Holes - Long Axis');
        xMin = min(measData.XData)-1;
        xMax = max(measData.XData)+1;

        tempAx = gca;
        copyobj(ax1.Children,tempAx);
        tempXLab = get(ax1,'XLabel');
        tempYLab = get(ax1,'YLabel');
        tempXGrid = get(ax1,'XGrid');
        tempYGrid = get(ax1,'YGrid');
        set(tempAx,'XLabel',tempXLab);
        set(tempAx,'YLabel',tempYLab);
        set(tempAx,'XGrid',tempXGrid);
        set(tempAx,'YGrid',tempYGrid);
        set(tempAx,'XLim',[xMin xMax]);
    else
        ax1 = handles.imSubPlot1;
        ax2 = handles.imSubPlot2;
        measData = findobj(ax1,'Tag','Holes - Long Axis');
        xMin = min(measData.XData)-1;
        xMax = max(measData.XData)+1;
        tempAx1 = subplot(211);
        tempAx2 = subplot(212);
        copyobj(ax1.Children,tempAx1);
        copyobj(ax2.Children,tempAx2);
        tempXLab = get(ax1,'XLabel');
        tempYLab = get(ax1,'YLabel');
        tempXGrid = get(ax1,'XGrid');
        tempYGrid = get(ax1,'YGrid');
        set(tempAx1,'XLabel',tempXLab);
        set(tempAx1,'YLabel',tempYLab);
        set(tempAx1,'XGrid',tempXGrid);
        set(tempAx1,'YGrid',tempYGrid);
        set(tempAx1,'XLim',[xMin xMax]);
        tempXLab = get(ax2,'XLabel');
        tempYLab = get(ax2,'YLabel');
        tempXGrid = get(ax2,'XGrid');
        tempYGrid = get(ax2,'YGrid');
        set(tempAx2,'XLabel',tempXLab);
        set(tempAx2,'YLabel',tempYLab);
        set(tempAx2,'XGrid',tempXGrid);
        set(tempAx2,'YGrid',tempYGrid);
        set(tempAx2,'XLim',[xMin xMax]);
    end

    OSvalue = get(handles.OSbuttongroup.SelectedObject,'String');
    if strcmp(OSvalue,'Windows')==1
        fSep = '\';
    elseif strcmp(OSvalue,'UNIX')==1
        fSep = '/';
    end

    %[imPlotName,imPlotPath] = uiputfile({'*.png';'*.fig';'*.jpg';'*.pdf';'*.tif'},'Save Image As','.');

    imFolder = get(handles.imFolder,'String');
    currentImPath = strcat(pwd(),fSep,imFolder,fSep);
    if exist('imData','var')~=1
        load(strcat(currentImPath,'imData.mat'));
    end
    imSel = get(handles.imSelPopUpMenu,'Value');
    currentImName = imData{imSel}.imName;
    if exist(strcat(currentImPath,'savedPlots'),'dir')~=7
        mkdir(strcat(currentImPath,'savedPlots'));
    end
    imPlotPath = strcat(currentImPath,'savedPlots',fSep);
    imPlotName = currentImName(1:end-4);
    nameCheck = false;
    increment = 2;
    while nameCheck == false
        if exist(strcat(imPlotPath,imPlotName,'.png'),'file')==2
            imPlotName = sprintf('%s_plt%i',currentImName(1:end-4),increment);
            increment = increment + 1;
        else
            nameCheck = true;
        end
    end
    saveas(tempFig,strcat(imPlotPath,imPlotName,'.fig'));
    saveas(tempFig,strcat(imPlotPath,imPlotName,'.png'));

    if handles.latexExportCheckbox.Value == 1

        if exist(strcat(imPlotPath,'latexFig',fSep),'dir')~=7
            mkdir(strcat(imPlotPath,'latexFig'));
        end
        matlab2tikz('figurehandle',tempFig,'showInfo',false,'showWarnings',false,...
                    strcat(imPlotPath,'latexFig',fSep,imPlotName(1:end-4),'.tex'),...
                    'width','\figurewidth','height','\figureheight');
    end
    clear tempFig;
    set(0,'DefaultFigureVisible','on')
    close(h);
else
    if resTest==0
        ax1 = handles.imPlot;

        tempAx = gca;
        copyobj(ax1.Children,tempAx);
        tempXLab = get(ax1,'XLabel');
        tempYLab = get(ax1,'YLabel');
        tempXGrid = get(ax1,'XGrid');
        tempYGrid = get(ax1,'YGrid');
        set(tempAx,'XLabel',tempXLab);
        set(tempAx,'YLabel',tempYLab);
        set(tempAx,'XGrid',tempXGrid);
        set(tempAx,'YGrid',tempYGrid);
    else
        ax1 = handles.imSubPlot1;
        ax2 = handles.imSubPlot2;
        tempAx1 = subplot(211);
        tempAx2 = subplot(212);
        copyobj(ax1.Children,tempAx1);
        copyobj(ax2.Children,tempAx2);
        tempXLab = get(ax1,'XLabel');
        tempYLab = get(ax1,'YLabel');
        tempXGrid = get(ax1,'XGrid');
        tempYGrid = get(ax1,'YGrid');
        set(tempAx1,'XLabel',tempXLab);
        set(tempAx1,'YLabel',tempYLab);
        set(tempAx1,'XGrid',tempXGrid);
        set(tempAx1,'YGrid',tempYGrid);
        tempXLab = get(ax2,'XLabel');
        tempYLab = get(ax2,'YLabel');
        tempXGrid = get(ax2,'XGrid');
        tempYGrid = get(ax2,'YGrid');
        set(tempAx2,'XLabel',tempXLab);
        set(tempAx2,'YLabel',tempYLab);
        set(tempAx2,'XGrid',tempXGrid);
        set(tempAx2,'YGrid',tempYGrid);
    end
    OSvalue = get(handles.OSbuttongroup.SelectedObject,'String');
%     if strcmp(OSvalue,'Windows')==1
%         fSep = '\';
%     elseif strcmp(OSvalue,'UNIX')==1
%         fSep = '/';
%     end

    [imPlotName,imPlotPath] = uiputfile({'*.png';'*.fig';'*.jpg';'*.pdf';'*.tif'},'Save Image As','.');
    saveas(tempFig,strcat(imPlotPath,imPlotName));
    clear tempFig;
    set(0,'DefaultFigureVisible','on')
    close(h);
end

% --- Executes on button press in imSaveButton.
function imSaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to imSaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = waitbar(0,'Saving image...');
% Screen resolution 
set(0,'Units','pixels')
scrRes = get(0,'screenSize');
scrW  = scrRes(3);
scrH = scrRes(4);

% Hide the temporary figure
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
tempAxCh = flip(tempAx.Children);

im2Rescale = findobj(tempAxCh,'Type','Image');
imCData= im2Rescale.CData;
imSize = size(imCData);
imSizeX = imSize(2);
imSizeY = imSize(1);

if scrW<imSizeX
    sclY = imSizeY/scrW;
    sclX = imSizeX/scrH;

    sclIm = max([sclX sclY]);

    imCData = imresize(imCData,1/sclIm);
    set(im2Rescale,'CData',imCData);
else
    sclIm = 1;
end

tempXLim = imSizeX / sclIm;
tempYLim = imSizeY / sclIm;


for i = 1:length(tempAxCh)
    objType = get(tempAxCh(i),'Type');
    switch objType
        case 'line'
            set(tempAxCh(i),'XData',get(tempAxCh(i),'XData')/sclIm);
            set(tempAxCh(i),'YData',get(tempAxCh(i),'YData')/sclIm);
        case 'text'
            set(tempAxCh(i),'Position',get(tempAxCh(i),'Position')/sclIm);
        case 'quiver'
            set(tempAxCh(i),'XData',get(tempAxCh(i),'XData')/sclIm);
            set(tempAxCh(i),'YData',get(tempAxCh(i),'YData')/sclIm);
            set(tempAxCh(i),'VData',get(tempAxCh(i),'VData')/sclIm);
            set(tempAxCh(i),'WData',get(tempAxCh(i),'WData')/sclIm);
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
set(gcf,'inverthardcopy','off')
set(gca,'YDir','reverse');

%[imName,imPath] = uiputfile({'*.png';'*.fig';'*.jpg';'*.pdf';'*.tif'},'Save Image As','.');

OSvalue = get(handles.OSbuttongroup.SelectedObject,'String');
if strcmp(OSvalue,'Windows')==1
    fSep = '\';
elseif strcmp(OSvalue,'UNIX')==1
    fSep = '/';
end

imFolder = get(handles.imFolder,'String');
currentImPath = strcat(pwd(),fSep,imFolder,fSep);
if exist('imData','var')~=1
    load(strcat(currentImPath,'imData.mat'));
end
imSel = get(handles.imSelPopUpMenu,'Value');
currentImName = imData{imSel}.imName;
if exist(strcat(currentImPath,'savedImages'),'dir')~=7
    mkdir(strcat(currentImPath,'savedImages'));
end
imPath = strcat(currentImPath,'savedImages',fSep);
imName = currentImName(1:end-4);
nameCheck = false;
increment = 2;
while nameCheck == false
    if exist(strcat(imPath,imName,'.png'),'file')==2
        imName = sprintf('%s_img%i',currentImName(1:end-4),increment);
        increment = increment + 1;
    else
        nameCheck = true;
    end
end

saveas(tempFig,strcat(imPath,imName,'.png'));
clear tempFig;
set(0,'DefaultFigureVisible','on')
close(h);


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


% --- Executes on button press in modelCheckbox.
function modelCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to modelCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')==1
    set(handles.residualCheckbox,'Enable','on');
    plotModel(handles);
else
    set(handles.residualCheckbox,'Enable','off');
    drawPlot(hObject,handles);
end
% Hint: get(hObject,'Value') returns toggle state of modelCheckbox


% --- Executes on button press in residualCheckbox.
function residualCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to residualCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
drawPlot(hObject,handles);
plotModel(handles);
% Hint: get(hObject,'Value') returns toggle state of residualCheckbox


% --- Executes on button press in resLengthCheckbox.
function resLengthCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to resLengthCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
drawPlot(hObject,handles);
plotModel(handles);
% Hint: get(hObject,'Value') returns toggle state of resLengthCheckbox


% --- Executes on button press in resHoldOnButton.
function resHoldOnButton_Callback(hObject, eventdata, handles)
% hObject    handle to resHoldOnButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(findobj('name','Length - Length difference'))==1
    resFig = figure('name','Length - Length difference');
    axes();
else
    resFig = findobj('name','Length - Length difference');
end
ax = resFig.Children;
plots = handles.imSubPlot2.Children;
copyobj(plots,ax);

%function slider1_CreateFcn(hObject, eventdata, handles)
%
%

% --- Executes on button press in latexExportCheckbox.
function latexExportCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to latexExportCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of latexExportCheckbox


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in imScaleCheckbox.
function imScaleCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to imScaleCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImage(handles);
% Hint: get(hObject,'Value') returns toggle state of imScaleCheckbox


% --- Executes on button press in beamWidthCheckbox.
function beamWidthCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to beamWidthCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImage(handles);
% Hint: get(hObject,'Value') returns toggle state of beamWidthCheckbox


% --- Executes on button press in holeIndexCheckbox.
function holeIndexCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to holeIndexCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImage(handles);
% Hint: get(hObject,'Value') returns toggle state of holeIndexCheckbox


% --- Executes on button press in pixelSizeCheckbox.
function pixelSizeCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to pixelSizeCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImage(handles);
% Hint: get(hObject,'Value') returns toggle state of pixelSizeCheckbox


% --- Executes on button press in statsButton.
function statsButton_Callback(hObject, eventdata, handles)
computeStatisticsFull(handles)
% hObject    handle to statsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadMasksCheckbox.
function loadMasksCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to loadMasksCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
pltList = cell(0);

masksFileInfo = get(handles.loadMasksButton,'UserData');
masksFileName = masksFileInfo.name;
masksFileChip = 1;%masksFileInfo.chip;
masksFileTest = exist(masksFileName,'file');

val = get(hObject,'Value');
switch val
    case 0
        set(handles.loadMasksButton,'Enable','off');
        
        pltList{1} = 'Holes - Long Axis';
        pltList{2} = 'Holes - Short Axis';
        pltList{3} = 'Holes - Holes Interval';
    case 1
        set(handles.loadMasksButton,'Enable','on');        
        
        if masksFileTest ~= 2
            [masksFileName,masksFilePathName] = uigetfile('*.mat','Select the masks file');
%             prompt = {'Enter the chip number (integer):'};
%             dlg_title = 'Chip number';
%             num_lines = 1;
%             masksFileChip = inputdlg(prompt,dlg_title,num_lines);
            usrdata.name = strcat(masksFilePathName,masksFileName);
            %usrdata.chip = masksFileChip;
            set(handles.loadMasksButton,'UserData',usrdata);
        end
        
        pltList{1} = 'p : Mask - Measured';
        pltList{2} = 'hx : Mask - Measured';
        pltList{3} = 'hy : Mask - Measured';
        pltList{4} = 'Beam Width : Mask - Measured';
        pltList{5} = 'Holes - Long Axis';
        pltList{6} = 'Holes - Short Axis';
        pltList{7} = 'Holes - Holes Interval';
        pltList{8} = 'All length : Mask - Measured';
        pltList{9} = 'All length : Curvature - Measured';
        
end

set(handles.plotAvailableListbox,'String',pltList);
set(handles.plotShownListbox,'String','');
drawPlot(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of loadMasksCheckbox


% --- Executes on button press in loadMasksButton.
function loadMasksButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadMasksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[masksFileName,masksFilePathName] = uigetfile('*.mat','Select the masks file');
% prompt = {'Enter the chip number (integer):'};
% dlg_title = 'Chip number';
% num_lines = 1;
% masksFileChip = inputdlg(prompt,dlg_title,num_lines);
usrdata.name = strcat(masksFilePathName,masksFileName);
%usrdata.chip = masksFileChip;
set(handles.loadMasksButton,'UserData',usrdata);
drawPlot(hObject,handles);



function currentChipText_Callback(hObject, eventdata, handles)
% hObject    handle to currentChipText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentChipText as text
%        str2double(get(hObject,'String')) returns contents of currentChipText as a double


% --- Executes during object creation, after setting all properties.
function currentChipText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentChipText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function loadMasksButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadMasksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
usrData.name = '';
usrData.chip = 1;
set(hObject,'UserData',usrData);


% --- Executes during object creation, after setting all properties.
function uibuttongroup4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
