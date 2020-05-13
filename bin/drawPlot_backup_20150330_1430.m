function drawPlot(hObject,handles)
    
    pltList = get(handles.plotShownListbox,'String');
    nPlt  = length(pltList);
    
    delete(handles.imPlot.Children);
    delete(handles.imSubPlot1.Children);
    delete(handles.imSubPlot2.Children);
    
    modelTest = 0;
    resTest = get(handles.residualCheckbox,'Value');
    
    if resTest == 0
        ax1 = handles.imPlot;
        set(handles.imSubPlot1,'Visible','off');
        set(handles.imSubPlot2,'Visible','off');
        set(handles.imPlot,'Visible','on');
        set(handles.imSubPlot1,'HitTest','off');
        set(handles.imSubPlot2,'HitTest','off');
        set(handles.imPlot,'HitTest','on');
        set(handles.imSubPlot1,'HandleVisibility','off');
        set(handles.imSubPlot2,'HandleVisibility','off');
        set(handles.imPlot,'HandleVisibility','on');
    else
        ax1 = handles.imSubPlot1;
        ax2 = handles.imSubPlot2;
        set(handles.imSubPlot1,'Visible','on');
        set(handles.imSubPlot2,'Visible','on');
        set(handles.imPlot,'Visible','off');
        set(handles.imSubPlot1,'HitTest','on');
        set(handles.imSubPlot2,'HitTest','on');
        set(handles.imPlot,'HitTest','off');
        set(handles.imSubPlot1,'HandleVisibility','on');
        set(handles.imSubPlot2,'HandleVisibility','on');
        set(handles.imPlot,'HandleVisibility','off');
    end
    
    load(strcat(handles.imFullPath,'imData.mat'));
    imDataMat = cell2mat(imData);
    sel = get(handles.imSelPopUpMenu,'Value');
    imNameList = get(handles.imSelPopUpMenu,'String');
    imName = imNameList{sel};
    scl = 0;
    for i = 1:length(imDataMat)
        if strcmp(imData{i}.imName,imName)~=0
            scl = imData{i}.imScale;
        end
    end

    
    for i = 1:nPlt
        switch pltList{i}
            case 'Dose - Mean Roughness'
                set(ax1,'NextPlot','replacechildren');
                dose = [imDataMat.imDose];
                imName = {imDataMat.imName};
                meanRough = [imDataMat.imMeanRough];
                if i~=1
                    hold(ax1,'on');
                end
                sc = scatter(ax1,dose(dose~=0),meanRough(dose~=0),'x');
                set(sc,'Tag','Dose - Mean Roughness');
                set(sc,'HitTest','off');
                usrdt.imName = imName(dose~=0);
                set(sc,'UserData',usrdt);
                if i == 1
                    xlabel(ax1,'Dose');
                    ylabel(ax1,'Mean Roughness');
                end
            case 'Dose - Long Axis'
                set(ax1,'NextPlot','replacechildren');
                lAx = [];
                dose = [];
                indIm = [];
                indHole = [];
                for j = 1:length(imData)
                    if (imData{j}.imDose)~=0
                        ell = cell2mat(imData{j}.ellipses);
                        dose = cat(1,dose,imData{j}.imDose*ones(length(ell),1));
                        lAx  = cat(1,lAx,[ell.long_axis]'*imData{j}.imScale);
                        indIm  = cat(2,indIm,j*ones(1,length(ell)));
                        indHole  = cat(2,indHole,linspace(1,length(ell),length(ell)));
                    end
                end
                if i~=1
                    hold(ax1,'on');
                end
                sc = scatter(ax1,dose(dose~=0),lAx(dose~=0),'x');
                set(sc,'Tag','Dose - Long Axis');
                set(sc,'HitTest','off');
                usrdt.indIm = indIm(dose~=0);
                usrdt.indHole = indHole(dose~=0);
                usrdt.selHole = 1;
                set(sc,'UserData',usrdt);
                if i == 1
                        xlabel(ax1,'Dose');
                        ylabel(ax1,'Length [nm]');
                end
            case 'Dose - Short Axis'
                set(ax1,'NextPlot','replacechildren');
                sAx = [];
                dose = [];
                indIm = [];
                indHole = [];
                for j = 1:length(imData)
                    if (imData{j}.imDose)~=0
                        ell = cell2mat(imData{j}.ellipses);
                        dose = cat(1,dose,imData{j}.imDose*ones(length(ell),1));
                        sAx  = cat(1,sAx,[ell.short_axis]'*imData{j}.imScale);
                        indIm  = cat(2,indIm,j*ones(1,length(ell)));
                        indHole  = cat(2,indHole,linspace(1,length(ell),length(ell)));
                    end
                end
                if i~=1
                    hold(ax1,'on');
                end
                sc = scatter(ax1,dose(dose~=0),sAx(dose~=0),'+');
                set(sc,'Tag','Dose - Short Axis');
                set(sc,'HitTest','off');
                usrdt.indIm = indIm(dose~=0);
                usrdt.indHole = indHole(dose~=0);
                usrdt.selHole = 1;
                set(sc,'UserData',usrdt);
                if i == 1
                        xlabel(ax1,'Dose');
                        ylabel(ax1,'Length [nm]');
                end
            case 'Dose - Beam Width'
                dose = [imDataMat.imDose];
                bW = [imDataMat.beamWidth];
                if i~=1
                    hold(ax1,'on');
                end
                sc = scatter(ax1,dose(dose~=0),bW(dose~=0),'x');
                set(sc,'Tag','Dose - Beam Width');
                if i == 1
                        xlabel(ax1,'Dose');
                        ylabel(ax1,'Length [nm]');
                end
            case 'Holes - Holes Interval'
                modelTest = 1;
                if imData{sel}.imDose~=0
                    ell = imData{sel}.ellipses;
                    holesNum = linspace(1,length(ell),length(ell));
                    intervX = linspace(1.5,holesNum(end)-0.5,length(holesNum)-1);
                    intervY = intervX;
                    for j = 1:length(intervY)
                        intervY(j) = scl*hypot( ell{j}.X0_in-ell{j+1}.X0_in , ell{j}.Y0_in-ell{j+1}.Y0_in );
                    end
                    if i~=1
                        hold(ax1,'on');
                    end
                    sc = scatter(ax1,intervX,intervY,'xg');
                    set(sc,'Tag','Holes - Holes Intervals');
                    set(sc,'HitTest','on');
                    if i == 1
                        xlabel(ax1,'Holes number');
                        ylabel(ax1,'Length [nm]');
                    end
                end
            case 'Holes - Long Axis'
                modelTest = 1;
                if imData{sel}.imDose~=0
                    ell = cell2mat(imData{sel}.ellipses);
                    holesNum = linspace(1,length(ell),length(ell));
                    lAx = [ell.a]*2*scl;
                    if i~=1
                        hold(ax1,'on');
                    end
                    sc = scatter(ax1,holesNum,lAx,'xb');
                    set(sc,'Tag','Holes - Long Axis');
                    set(sc,'HitTest','on');
                    if i == 1
                        xlabel(ax1,'Holes number');
                        ylabel(ax1,'Length [nm]');
                        hold(ax1,'on');
                    end
                end
            case 'Holes - Short Axis'
                modelTest = 1;
                if imData{sel}.imDose~=0
                    ell = cell2mat(imData{sel}.ellipses);
                    holesNum = linspace(1,length(ell),length(ell));
                    sAx = [ell.b]*2*scl;
                    if i~=1
                        hold(ax1,'on');
                    end
                    sc = scatter(ax1,holesNum,sAx,'xr');
                    set(sc,'Tag','Holes - Short Axis');
                    set(sc,'HitTest','on');
                    if i == 1
                        xlabel(ax1,'Holes number');
                        ylabel(ax1,'Length [nm]');
                    end
                end
            otherwise
                write2commandHistory(handles,'This plot type was added but is unknown of the drawPlot() function. Please add this plot to the switch block in drawPlot');
        end
    end
    grid(ax1,'on');
    set(ax1,'FontSize',17);
    axis(ax1,'auto');
    if resTest==1
        xlabel(ax2,'Holes number');
        ylabel(ax2,'Difference [nm]');
        grid(ax2,'on');
        set(ax2,'FontSize',17);
        axis(ax2,'auto');
    end
    highlightPlot(handles,imDataMat);
    
    if modelTest==1
        set(handles.modelCheckbox,'Enable','on');
        set(handles.slider1,'Enable','on');
        plotModel(handles);
    else
        set(handles.modelCheckbox,'Enable','off'); 
        set(handles.slider1,'Enable','off');
        set(handles.modelCheckbox,'Value',0);
    end
    if strcmp('on',get(handles.modelCheckbox,'Enable'))==0
        set(handles.residualCheckbox,'Enable','off');
        set(handles.residualCheckbox,'Value',0);
    else
        set(handles.residualCheckbox,'Enable','on');
    end

end