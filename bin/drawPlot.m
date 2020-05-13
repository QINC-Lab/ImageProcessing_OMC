function drawPlot(hObject,handles)
    h = waitbar(0,'Loading...');
    pltList = get(handles.plotShownListbox,'String');
    nPlt  = length(pltList);
    
    delete(handles.imPlot.Children);
    delete(handles.imSubPlot1.Children);
    delete(handles.imSubPlot2.Children);
    
    modelTest = 0;
    if length(cell2mat(strfind(pltList,'Holes -')))>0
        modelTest = 1;
    end
    if length(cell2mat(strfind(pltList,'Length -')))>0
        modelTest = 1;
    end
    
    if modelTest==1
        set(handles.modelCheckbox,'Enable','on');
    else
        set(handles.modelCheckbox,'Enable','off'); 
        set(handles.modelCheckbox,'Value',0);
        set(handles.residualCheckbox,'Enable','off');
        set(handles.residualCheckbox,'Value',0);
        set(handles.resHoldOnButton,'Enable','off');
        set(handles.resLengthCheckbox,'Enable','off');
        set(handles.resLengthCheckbox,'Value',0);
    end
    if get(handles.modelCheckbox,'Value')==0
        set(handles.residualCheckbox,'Enable','off');
        set(handles.residualCheckbox,'Value',0);
        set(handles.resHoldOnButton,'Enable','off');
        set(handles.resLengthCheckbox,'Enable','off');
        set(handles.resLengthCheckbox,'Value',0);
    else
        set(handles.residualCheckbox,'Enable','on');
        set(handles.resHoldOnButton,'Enable','on');
        set(handles.resLengthCheckbox,'Enable','on');
    end
               
    resTest = get(handles.residualCheckbox,'Value');
    resLengthTest = get(handles.resLengthCheckbox,'Value');
    
    if resTest == 0
        handles.resHoldOn = [];
        guidata(hObject,handles);
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
    [shArray,chArray] = findHolePosition(handles);
    sh = shArray(sel);
    ch = chArray(sel);
    
    loadModelTest = get(handles.loadMasksCheckbox,'Value');
    if loadModelTest == 1
        masksFile = get(handles.loadMasksButton,'UserData');
        load(masksFile.name);
        %chip = masksFile.chip;
    end
    
    
    for i = 1:nPlt
        switch pltList{i}
            case 'p : Mask - Measured'
                set(ax1,'NextPlot','replacechildren');
                
                %indIm = [];
                %indHole = [];
                mask = fabMasks{imData{sel}.imChip,imData{sel}.imSample,imData{sel}.imPhCry};
                pMask = mask.p;
                hMask = mask.hInd;
                chMask = find(hMask==0);
                ell = cell2mat(imData{sel}.ellipses);
                xCen = [ell.X0_in];
                yCen = [ell.Y0_in];
                pMeas  = scl(sel)*hypot(xCen(2:end)-xCen(1:end-1),yCen(2:end)-yCen(1:end-1));
                %indIm  = cat(2,indIm,j*ones(1,length(ell)));
                %indHole  = cat(2,indHole,linspace(1,length(ell),length(ell)));

                if i~=1
                    hold(ax1,'on');
                end
                sc = scatter(ax1,pMask(chMask-(ch-sh)-1:chMask+(ch-sh)),pMeas,'xg');
                set(sc,'Tag','p : Mask - Measured');
                %set(sc,'HitTest','off');
                %usrdt.indIm = indIm(dose~=0);
                %usrdt.indHole = indHole(dose~=0);
                %usrdt.selHole = 1;
                %set(sc,'UserData',usrdt);
                if i == 1
                        xlabel(ax1,'Mask Length [nm]');
                        ylabel(ax1,'Measured Length [nm]');
                end
            case 'hx : Mask - Measured'
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
            case 'hy : Mask - Measured'
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
            case 'Beam Width : Mask - Measured'
                dose = [imDataMat.imDose];
                bW = [imDataMat.beamWidth];
                indIm = linspace(1,length(dose),length(dose));
                if i~=1
                    hold(ax1,'on');
                end
                sc = scatter(ax1,dose(dose~=0),bW(dose~=0),'x');
                set(sc,'HitTest','off');
                usrdt.indIm = indIm(dose~=0);
                set(sc,'UserData',usrdt);
                set(sc,'Tag','Dose - Beam Width');
                if i == 1
                        xlabel(ax1,'Dose');
                        ylabel(ax1,'Length [nm]');
                end
            case 'Holes - Holes Interval'
                %modelTest = 1;
                if imData{sel}.imDose~=0
                    ell = imData{sel}.ellipses;
                    holesNum = linspace(1,length(ell),length(ell));
                    intervX = linspace(1.5-ch+sh,holesNum(end)-0.5-ch+sh,length(holesNum)-1);
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
                        xlabel(ax1,'Hole index');
                        ylabel(ax1,'L [nm]');
                    end
                end
            case 'Holes - Long Axis'
                %modelTest = 1;
                if imData{sel}.imDose~=0
                    ell = cell2mat(imData{sel}.ellipses);
                    holesNum = linspace(1-ch+sh,length(ell)-ch+sh,length(ell));
                    lAx = [ell.a]*2*scl;
                    if i~=1
                        hold(ax1,'on');
                    end
                    sc = scatter(ax1,holesNum,lAx,'xb');
                    set(sc,'Tag','Holes - Long Axis');
                    set(sc,'HitTest','on');
                    if i == 1
                        xlabel(ax1,'Hole index');
                        ylabel(ax1,'L [nm]');
                        hold(ax1,'on');
                    end
                end
            case 'Holes - Short Axis'
                %modelTest = 1;
                if imData{sel}.imDose~=0
                    ell = cell2mat(imData{sel}.ellipses);
                    holesNum = linspace(1-ch+sh,length(ell)-ch+sh,length(ell));
                    sAx = [ell.b]*2*scl;
                    if i~=1
                        hold(ax1,'on');
                    end
                    sc = scatter(ax1,holesNum,sAx,'xr');
                    set(sc,'Tag','Holes - Short Axis');
                    set(sc,'HitTest','on');
                    if i == 1
                        xlabel(ax1,'Hole index');
                        ylabel(ax1,'L [nm]');
                    end
                end
            case 'All length : Mask - Measured'
                shArray = findHolePosition(handles,imData);
                hold(ax1,'on');
%                 colArray = {'r','b','g','k','m'};
                for k = 1:length(imData)
                    imScl = imData{k}.imScale;
                    dose = imData{k}.imDose;
                    %if dose~=0
                    if dose == 155   % restricts to the 155 dose only ------
                        switch imData{k}.imDose
                            case 120
                                col = 'b';
                            case 145
                                col = 'r';
                            case 155
                                col = 'g';
                            case 160
                                col = 'k';
                            case 165
                                col = 'm';
                        end
                        %col = [(dose-120)/45,0,(165-dose)/45];
                        ell = cell2mat(imData{k}.ellipses);
                        lAx = [ell.a]*2*imScl;
                        sAx = [ell.b]*2*imScl;
                        [Hx,Hy,~,bW] = getModelValues();
                        bwM = imData{k}.beamWidth;
                        sh = shArray(k);
                        sc = scatter(ax1,Hx(1+sh:sh+length(lAx)),lAx'-Hx(1+sh:sh+length(lAx)),'s','MarkerEdgeColor',col);
                        %sc = scatter(ax1,dose*ones(size(lAx)),lAx'-Hx(1+sh:sh+length(lAx)),'sb');
                        set(sc,'Tag','Long Axis');
                        set(sc,'HitTest','off');
                        sc = scatter(ax1,Hy(1+sh:sh+length(lAx)),sAx'-Hy(1+sh:sh+length(lAx)),'^','MarkerEdgeColor',col);
                        %sc = scatter(ax1,dose*ones(size(sAx)),sAx'-Hy(1+sh:sh+length(sAx)),'^r');
                        set(sc,'Tag','Short Axis');
                        set(sc,'HitTest','off');
                        sc = scatter(ax1,bW,bW-bwM,'o','MarkerEdgeColor',col);
                        %sc = scatter(ax1,dose*ones(size(bW)),bW-bwM,'og');
                        set(sc,'Tag','Beam Width');
                        set(sc,'HitTest','off');
                        if i == 1
                            xlabel(ax1,'Length measured [nm]');
                            ylabel(ax1,'Length difference (meas-tar) [nm]');
                        end
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
        if resLengthTest == 1
            xlabel(ax2,'L [nm]');
        else
            xlabel(ax2,'Hole index');
        end
        ylabel(ax2,'\Delta L [nm]');
        grid(ax2,'on');
        set(ax2,'FontSize',17);
        axis(ax2,'auto');
    end
    highlightPlot(handles,imDataMat);
    
    if resTest==1
        plotModel(handles);
    end
    close(h);
end