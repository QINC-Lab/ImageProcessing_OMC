function drawPlot(hObject,handles)
    
    pltList = get(handles.plotShownListbox,'String');
    nPlt  = length(pltList);
    
    ax = handles.imPlot;
    cla(ax);
    set(ax,'NextPlot','replacechildren');
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
                dose = [imDataMat.imDose];
                meanRough = [imDataMat.imMeanRough];
                sc = scatter(ax,dose(dose~=0),meanRough(dose~=0),'x');
                set(sc,'UserData','Dose - Mean Roughness');
                set(sc,'HitTest','off');
                if i == 1
                    xlabel(ax,'Dose');
                    ylabel(ax,'Mean Roughness');
                    hold(ax,'on');
                end
            case 'Dose - Long Axis'
                lAx = [];
                dose = [];
                for j = 1:length(imData)
                    if (imData{j}.imDose)~=0
                        ell = cell2mat(imData{j}.ellipses);
                        dose = cat(1,dose,imData{j}.imDose*ones(length(ell),1));
                        lAx  = cat(1,lAx,[ell.long_axis]'*imData{j}.imScale);
                    end
                end
                sc = scatter(ax,dose(dose~=0),lAx(dose~=0),'x');
                set(sc,'UserData','Dose - Long Axis');
                if i == 1
                        xlabel(ax,'Dose');
                        ylabel(ax,'Length [nm]');
                        hold(ax,'on');
                end
            case 'Dose - Short Axis'
                sAx = [];
                dose = [];
                for j = 1:length(imData)
                    if (imData{j}.imDose)~=0
                        ell = cell2mat(imData{j}.ellipses);
                        dose = cat(1,dose,imData{j}.imDose*ones(length(ell),1));
                        sAx  = cat(1,sAx,[ell.short_axis]'*imData{j}.imScale);
                    end
                end
                sc = scatter(ax,dose(dose~=0),sAx(dose~=0),'x');
                set(sc,'UserData','Dose - Short Axis');
                if i == 1
                        xlabel(ax,'Dose');
                        ylabel(ax,'Length [nm]');
                        hold(ax,'on');
                end
            case 'Dose - Beam Width'
                dose = [imDataMat.imDose];
                bW = [imDataMat.beamWidth];
                sc = scatter(ax,dose(dose~=0),bW(dose~=0),'x');
                set(sc,'UserData','Dose - Beam Width');
                if i == 1
                        xlabel(ax,'Dose');
                        ylabel(ax,'Length [nm]');
                        hold(ax,'on');
                end
            case 'Holes - Holes Interval'
                if imData{sel}.imDose~=0
                    ell = imData{sel}.ellipses;
                    holesNum = linspace(1,length(ell),length(ell));
                    intervX = linspace(1.5,holesNum(end)-0.5,length(holesNum)-1);
                    intervY = intervX;
                    for j = 1:length(intervY)
                        intervY(j) = scl*hypot( ell{j}.X0_in-ell{j+1}.X0_in , ell{j}.Y0_in-ell{j+1}.Y0_in );
                    end
                    sc = scatter(ax,intervX,intervY,'x');
                    set(sc,'UserData','Holes - Holes Intervals');
                    set(sc,'HitTest','off');
                    if i == 1
                        xlabel(ax,'Holes number');
                        ylabel(ax,'Length [nm]');
                        hold(ax,'on');
                    end
                end
            case 'Holes - Long Axis'
                if imData{sel}.imDose~=0
                    ell = cell2mat(imData{sel}.ellipses);
                    holesNum = linspace(1,length(ell),length(ell));
                    lAx = [ell.long_axis]*scl;
                    sc = scatter(ax,holesNum,lAx,'+');
                    set(sc,'UserData','Holes - Long Axis');
                    set(sc,'HitTest','off');
                    if i == 1
                        xlabel(ax,'Holes number');
                        ylabel(ax,'Length [nm]');
                        hold(ax,'on');
                    end
                end
            case 'Holes - Short Axis'
                if imData{sel}.imDose~=0
                    ell = cell2mat(imData{sel}.ellipses);
                    holesNum = linspace(1,length(ell),length(ell));
                    sAx = [ell.short_axis]*scl;
                    sc = scatter(ax,holesNum,sAx,'o');
                    set(sc,'UserData','Holes - Short Axis');
                    set(sc,'HitTest','off');
                    if i == 1
                        xlabel(ax,'Holes number');
                        ylabel(ax,'Length [nm]');
                        hold(ax,'on');
                    end
                end
            otherwise
                write2commandHistory(handles,'This plot type was added but is unknown of the drawPlot() function. Please add this plot to the switch block in drawPlot');
        end
    end
    hold(ax,'off');
    grid(ax,'on');
    set(ax,'FontSize',17);
    axis(ax,'auto');
    highlightPlot(handles,imDataMat);


end