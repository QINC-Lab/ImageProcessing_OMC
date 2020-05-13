function displayImage(handles)
    h = waitbar(0,'Loading...');
    axIm = handles.im;
    delete(axIm.Children);
    hold(axIm,'on');

    edgeR = get(handles.beamRawBox,'Value');
    edgeI = get(handles.beamIntBox,'Value');
    edgeF = get(handles.beamFitBox,'Value');
    holesR = get(handles.holesRawBox,'Value');
    holesI = get(handles.holesIntBox,'Value');
    holesF = get(handles.holesFitBox,'Value');

    val = get(handles.imSelPopUpMenu,'Value');
    
    pltList = get(handles.plotShownListbox,'String');
    nPlt  = length(pltList);
    
    selHole = 0;
    
    ax = handles.imPlot;
    for i = 1:nPlt
        switch pltList{i}
            case 'Dose - Long Axis'
                sc = findobj(ax,'Tag',pltList{i});
                selHole = sc.UserData.selHole;
            case 'Dose - Short Axis'
                sc = findobj(ax,'Tag',pltList{i});
                selHole = sc.UserData.selHole;
        end
    end
    
    imType = get(handles.imTypeButtongroup.SelectedObject,'String');
    switch imType
        case 'Cropped Image'  
            if strcmp(handles.OS,'win')==1
                im = imread(strcat(handles.imFullPath,'\cropIm\',handles.listImNames{val}));
            elseif strcmp(handles.OS,'unix')==1
                im = imread(strcat(handles.imFullPath,'/cropIm/',handles.listImNames{val}));
            end
        case 'Black/White Image'
            if strcmp(handles.OS,'win')==1
                im = imread(strcat(handles.imFullPath,'\bwIm\',handles.listImNames{val}));
            elseif strcmp(handles.OS,'unix')==1
                im = imread(strcat(handles.imFullPath,'/bwIm/',handles.listImNames{val}));
            end
        case 'Original Image'
            im = imread(handles.listImFullPath{val});
    end
    axes(axIm);
    ims = imshow(im);
%     ims.HitTest = 'off';
%     ims.ButtonDownFcn = handles.im.ButtonDownFcn;
    
    if exist(strcat(handles.imFullPath,'imData.mat'),'var')~=1
        load(strcat(handles.imFullPath,'imData.mat'));
    end
    if edgeR == 1 && imData{val}.imContrast==1
        pl = plot(axIm,imData{val}.topEdgeRaw(:,2),imData{val}.topEdgeRaw(:,1),'-y');
        pl.HitTest = 'off';
        pl = plot(axIm,imData{val}.bottomEdgeRaw(:,2),imData{val}.bottomEdgeRaw(:,1),'-y');
        pl.HitTest = 'off';
    end
    if edgeI == 1 && imData{val}.imContrast==1
        pl = plot(axIm,imData{val}.topEdgeInt(:,2),imData{val}.topEdgeInt(:,1),'-c');
        pl.HitTest = 'off';
        pl = plot(axIm,imData{val}.bottomEdgeInt(:,2),imData{val}.bottomEdgeInt(:,1),'-c');
        pl.HitTest = 'off';
    end
    if edgeF == 1 && imData{val}.imContrast==1
        pl = plot(axIm,imData{val}.topEdgeFit(:,2),imData{val}.topEdgeFit(:,1),'-r');
        pl.HitTest = 'off';
        pl = plot(axIm,imData{val}.bottomEdgeFit(:,2),imData{val}.bottomEdgeFit(:,1),'-r');
        pl.HitTest = 'off';
    end
    if holesR == 1 && imData{val}.imContrast==1
        nH = length(imData{val}.holesRaw);
        for k = 1:nH
            pl = plot(axIm,imData{val}.holesRaw{k}(:,2),imData{val}.holesRaw{k}(:,1),'-m');
            pl.HitTest = 'off';
            if k == selHole
                fi = fill(imData{val}.holesRaw{k}(:,2),imData{val}.holesRaw{k}(:,1),'-m','FaceAlpha',0.2,'EdgeColor','none');
                fi.HitTest = 'off';
            end
                
        end
    end
    if holesI == 1 && imData{val}.imContrast==1
        nH = length(imData{val}.holesInt);
        for k = 1:nH
            pl = plot(axIm,imData{val}.holesInt{k}(:,2),imData{val}.holesInt{k}(:,1),'-g');
            pl.HitTest = 'off';
            if k == selHole
                fi = fill(imData{val}.holesRaw{k}(:,2),imData{val}.holesRaw{k}(:,1),'-g','FaceAlpha',0.2,'EdgeColor','none');
                fi.HitTest = 'off';
            end
        end
    end
    if holesF == 1 && imData{val}.imContrast==1
        nH = length(imData{val}.holesFit);
        for k = 1:nH
            pl = plot(axIm,imData{val}.holesFit{k}(:,1),imData{val}.holesFit{k}(:,2),'-b');
            pl.HitTest = 'off';
            if k == selHole
                fi = fill(imData{val}.holesRaw{k}(:,2),imData{val}.holesRaw{k}(:,1),'-b','FaceAlpha',0.2,'EdgeColor','none');
                fi.HitTest = 'off';
            end
        end
    end
    if imData{val}.imContrast==0
        write2commandHistory(handles,'Boundaries detection could not be done on this image');
%         set(handles.commandHistory,'ForegroundColor','red');
%         set(handles.commandHistory,'String','Boundaries detection could not be done on this image');drawnow;
    end
    
    % Drawing scale
    if handles.imScaleCheckbox.Value==1
        scl = imData{val}.imScale; % image scale nm/px
        [imH,imW] = size(im);       % image resolution

        est = 0.1*imW*scl; % Estimation of the scale size
        sclChoice = [100 500 1000]; % List of scales
        sclDiff = abs(sclChoice-est);
        choice  = find(sclDiff==min(sclDiff));

        sclLine = round(0.95*imW)-round(sclChoice(choice)/scl):round(0.95*imW);
        plot(axIm,sclLine,ones(size(sclLine))*round(0.95*imH),'-w');
        plot(axIm,[sclLine(1) sclLine(1)],[round(0.925*imH) round(0.975*imH)],'-w');
        plot(axIm,[sclLine(end) sclLine(end)],[round(0.925*imH) round(0.975*imH)],'-w');
        switch sclChoice(choice)
            case 100
                text(sclLine(round(0.5*length(sclLine))),round(0.9*imH),'100 [nm]','FontSize',16,'HorizontalAlignment','center','Color','white');
            case 500
                text(sclLine(round(0.5*length(sclLine))),round(0.9*imH),'500 [nm]','FontSize',16,'HorizontalAlignment','center','Color','white');
            case 1000
                text(sclLine(round(0.5*length(sclLine))),round(0.9*imH),'1 [\mum]','FontSize',16,'HorizontalAlignment','center','Color','white');
        end
    end
    
    % Drawing beam width
    if handles.beamWidthCheckbox.Value==1
        bw = imData{val}.beamWidth; % beam width
        [imH,imW] = size(im);       % image resolution
        %imData{val}.topEdgeFit(:,1)
        xPos = round(0.1*imW);
        bin1 = find(imData{val}.topEdgeFit(:,2)-xPos == min(imData{val}.topEdgeFit(:,2)-xPos));
        bin2 = find(imData{val}.bottomEdgeFit(:,2)-xPos == min(imData{val}.bottomEdgeFit(:,2)-xPos));
        quiver(axIm,xPos,mean(imData{val}.topEdgeFit(bin1,1))-0.1*imH,0,0.097*imH,0,'Color','white','MaxHeadSize',1.5);
        quiver(axIm,xPos,mean(imData{val}.bottomEdgeFit(bin2,1)+0.1*imH),0,-0.097*imH,0,'Color','white','MaxHeadSize',1.5);

        strBeamWidth = sprintf('%1.1f [nm]',bw);
        text(xPos+0.01*imW,mean(imData{val}.topEdgeFit(bin1,1))-0.08*imH,strBeamWidth,'FontSize',16,'Color','white');
    end
    
    % Drawing the hole indices
    if handles.holeIndexCheckbox.Value==1
       [sh,ch] = findHolePosition(handles);
       ell = imData{val}.ellipses;
       nH = length(ell);
       indH = linspace(1-ch(val)+sh(val),nH-ch(val)+sh(val),nH);
       for k = 1:nH
           strIndH = sprintf('%i',indH(k));
           text(ell{k}.X0_in,ell{k}.Y0_in,strIndH,'FontSize',16,'Color','white','HorizontalAlignment','center');
       end
    end
    
    % Drawing the pixel size
    if handles.pixelSizeCheckbox.Value==1
       scl = imData{val}.imScale; % image scale nm/px
       [imH,imW] = size(im);       % image resolution
       strPixSize = sprintf('%1.2f [nm/px]',scl);
       text(round(0.6*imW),round(0.9*imH),strPixSize,'FontSize',16,'HorizontalAlignment','center','Color','white');
    end
    close(h);
end