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
        set(handles.resLengthCheckbox,'Enable','off');
        set(handles.resLengthCheckbox,'Value',0);
    end
    if get(handles.modelCheckbox,'Value')==0
        set(handles.resLengthCheckbox,'Enable','off');
        set(handles.resLengthCheckbox,'Value',0);
    else
        set(handles.residualCheckbox,'Enable','on');
        set(handles.resHoldOnButton,'Enable','on');
        set(handles.resLengthCheckbox,'Enable','on');
    end
    
    if length(cell2mat(strfind(pltList,'All length')))>0
        set(handles.residualCheckbox,'Enable','on');
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
    [~,hy,~,~] = getModelValues();
    
    loadModelTest = get(handles.loadMasksCheckbox,'Value');
    if loadModelTest == 1
        masksFile = get(handles.loadMasksButton,'UserData');
        load(masksFile.name);
        %chip = masksFile.chip;
    end
    
    imScl = [imDataMat.imScale];
    
    for i = 1:nPlt
        switch pltList{i}
            case 'p : Mask - Measured'
                if imScl(sel)~=0
                    set(ax1,'NextPlot','replacechildren');               
                    mask = fabMasks{imData{sel}.imChip,imData{sel}.imSample,imData{sel}.imPhCry};
                    pMask = mask.p;
                    hMask = mask.hInd;
                    chMask = find(hMask==0);
                    ell = cell2mat(imData{sel}.ellipses);
                    xCen = [ell.X0_in];
                    yCen = [ell.Y0_in];
                    pMeas  = imScl(sel)*hypot(xCen(2:end)-xCen(1:end-1),yCen(2:end)-yCen(1:end-1));

                    if i~=1
                        hold(ax1,'on');
                    end
                    % sc = scatter(ax1,pMask(chMask-(ch-sh)-1:chMask-(ch-sh)-1+length(pMeas)-1),pMeas,'xg');
                    sc = scatter(ax1,pMask(chMask-(ch-sh)+1:chMask-(ch-sh)+1+length(pMeas)-1),pMeas,'xg');
                    set(sc,'Tag','p : Mask - Measured');
                    
                    if resTest == 1
                        hold(ax2,'on');
                        scatter(ax2,pMask(1+chMask-chMeas:chMask-chMeas+length(pMeas)),pMeas-pMask(1+chMask-chMeas:chMask-chMeas+length(pMeas)),'xg');       
                    end
                    
                end
                if resTest == 1
                    scatter(ax2,bwMasks(bwMasks~=0),bwMeas(bwMeas~=0)-bwMasks(bwMasks~=0),'xk');
                    xlabel(ax2,'Masks length [nm]');
                    ylength(ax2,'\Delta L [nm]');
                end
                if i == 1
                        xlabel(ax1,'Mask Length [nm]');
                        ylabel(ax1,'Measured Length [nm]');
                end
                
                
            case 'hx : Mask - Measured'
                if imScl(sel)~=0
                    set(ax1,'NextPlot','replacechildren');

                    mask = fabMasks{imData{sel}.imChip,imData{sel}.imSample,imData{sel}.imPhCry};
                    hxMask = mask.hx;
                    hMask = mask.hInd;
                    chMask = find(hMask==0);
                    ell = cell2mat(imData{sel}.ellipses);

                    hxMeas  = 2*imScl(sel)*[ell.a];

                    if i~=1
                        hold(ax1,'on');
                    end
                    %sc = scatter(ax1,hxMask(chMask-(ch-sh)-1:chMask-(ch-sh)-1+length(hxMeas)-1),hxMeas,'xb');
                    sc = scatter(ax1,hxMask(chMask-(ch-sh)+1:chMask-(ch-sh)+1+length(hxMeas)-1),hxMeas,'xb');
                    set(sc,'Tag','hx : Mask - Measured');
                    
                    if resTest == 1
                        hold(ax2,'on');
                        scatter(ax2,hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hxMeas-hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),'xb'); 
                    end
                end
                if resTest == 1
                    scatter(ax2,bwMasks(bwMasks~=0),bwMeas(bwMeas~=0)-bwMasks(bwMasks~=0),'xk');
                    xlabel(ax2,'Masks length [nm]');
                    ylength(ax2,'\Delta L [nm]');
                end
                if i == 1
                        xlabel(ax1,'Mask Length [nm]');
                        ylabel(ax1,'Measured Length [nm]');
                end
            case 'hy : Mask - Measured'
                if imScl(sel)~=0
                    set(ax1,'NextPlot','replacechildren');

                    mask = fabMasks{imData{sel}.imChip,imData{sel}.imSample,imData{sel}.imPhCry};
                    hyMask = mask.hy;
                    hMask = mask.hInd;
                    chMask = find(hMask==0);
                    ell = cell2mat(imData{sel}.ellipses);

                    hyMeas  = 2*imScl(sel)*[ell.b];

                    if i~=1
                        hold(ax1,'on');
                    end
                    % sc = scatter(ax1,hyMask(chMask-(ch-sh)-1:chMask-(ch-sh)-1+length(hyMeas)-1),hyMeas,'xr');
                    sc = scatter(ax1,hyMask(chMask-(ch-sh)+1:chMask-(ch-sh)+1+length(hyMeas)-1),hyMeas,'xr');
                    set(sc,'Tag','hy : Mask - Measured');
                    
                    if resTest == 1
                        hold(ax2,'on');
                        scatter(ax2,hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),hyMeas-hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),'xr');   
                    end
                end
                if resTest == 1
                    scatter(ax2,bwMasks(bwMasks~=0),bwMeas(bwMeas~=0)-bwMasks(bwMasks~=0),'xk');
                    xlabel(ax2,'Masks length [nm]');
                    ylength(ax2,'\Delta L [nm]');
                end
                if i == 1
                        xlabel(ax1,'Mask Length [nm]');
                        ylabel(ax1,'Measured Length [nm]');
                end
            case 'Beam Width : Mask - Measured'
                nIm = length([imDataMat.imDose]~=0);
                bwMasks = zeros(1,nIm);
                bwMeas  = zeros(1,nIm);
                set(ax1,'NextPlot','replacechildren');
                for kIm = 1:nIm
                    if imScl(kIm)~=0
                        mask = fabMasks{imData{kIm}.imChip,imData{kIm}.imSample,imData{kIm}.imPhCry};
                        bwMasks(kIm) = mask.bw;

                        bwMeas(kIm) = imData{kIm}.beamWidth;
                    end
                end
                if i~=1
                    hold(ax1,'on');
                end
                sc = scatter(ax1,bwMasks(bwMasks~=0),bwMeas(bwMeas~=0),'xk');
                set(sc,'Tag','Beam Width : Mask - Measured');
                if resTest == 1
                    scatter(ax2,bwMasks(bwMasks~=0),bwMeas(bwMeas~=0)-bwMasks(bwMasks~=0),'xk');
                    xlabel(ax2,'Masks length [nm]');
                    ylabel(ax2,'\Delta L [nm]');
                end
                if i == 1
                        xlabel(ax1,'Mask Length [nm]');
                        ylabel(ax1,'Measured Length [nm]');
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
                    if resTest == 1
                        if resLengthTest == 1
                            xlabel(ax2,'L [nm]');
                        else
                            xlabel(ax2,'Hole index');
                        end
                        ylabel(ax2,'\Delta L [nm]');
                    end
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
                    if resTest == 1
                        if resLengthTest == 1
                            xlabel(ax2,'L [nm]');
                        else
                            xlabel(ax2,'Hole index');
                        end
                        ylabel(ax2,'\Delta L [nm]');
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
                    if resTest == 1
                        if resLengthTest == 1
                            xlabel(ax2,'L [nm]');
                        else
                            xlabel(ax2,'Hole index');
                        end
                        ylabel(ax2,'\Delta L [nm]');
                    end
                    if i == 1
                        xlabel(ax1,'Hole index');
                        ylabel(ax1,'L [nm]');
                    end
                end
            case 'All length : Mask - Measured'
                nIm = length([imDataMat.imDose]~=0);
                bwMasks = zeros(1,nIm);
                bwMeas  = zeros(1,nIm);
                set(ax1,'NextPlot','replacechildren');
                hold(ax1,'on');
                for kIm = 1:nIm
                    if imScl(kIm)~=0 && imData{kIm}.imPhCry>0
                        mask = fabMasks{imData{kIm}.imChip,imData{kIm}.imSample,imData{kIm}.imPhCry};
                        bwMasks(kIm) = mask.bw;

                        bwMeas(kIm) = imData{kIm}.beamWidth;
                        pMask = mask.p;
                        hxMask = mask.hx;
                        hyMask = mask.hy;
                        hMask = mask.hInd;
                        chMask = find(hMask==0);
                        ell = cell2mat(imData{kIm}.ellipses);
                        xCen = [ell.X0_in];
                        yCen = [ell.Y0_in];
                        pMeas  = imScl(kIm)*hypot(xCen(2:end)-xCen(1:end-1),yCen(2:end)-yCen(1:end-1));
                        hxMeas  = 2*imScl(kIm)*[ell.a];
                        hyMeas  = 2*imScl(kIm)*[ell.b];
                        
                        chMeas = find(hy(1+shArray(kIm):sh+length(hyMeas))==min(hy(1+shArray(kIm):sh+length(hyMeas))));
                        if imData{kIm}.imPhCry > 5 && chMask>=chMeas
                            sc = scatter(ax1,pMask(1+chMask-chMeas:chMask-chMeas+length(pMeas)),pMeas,'xg');
                            set(sc,'Tag','p : Mask - Measured');                       
                            sc = scatter(ax1,hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hxMeas,'xb');
                            set(sc,'Tag','hy : Mask - Measured');
                            sc = scatter(ax1,hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),hyMeas,'xr');
                            set(sc,'Tag','hy : Mask - Measured');
                        elseif chMask>=chMeas
                            sc = scatter(ax1,pMask(1+chMask-chMeas:chMask-chMeas+length(pMeas)),pMeas,'og');
                            set(sc,'Tag','p : Mask - Measured');                       
                            sc = scatter(ax1,hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hxMeas,'ob');
                            set(sc,'Tag','hy : Mask - Measured');
                            sc = scatter(ax1,hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),hyMeas,'or');
                            set(sc,'Tag','hy : Mask - Measured');
                        end
                        if resTest == 1
                            hold(ax2,'on');
                            if imData{kIm}.imPhCry > 5 && chMask>=chMeas
                                scatter(ax2,pMask(1+chMask-chMeas:chMask-chMeas+length(pMeas)),pMeas-pMask(1+chMask-chMeas:chMask-chMeas+length(pMeas)),'xg');
                                scatter(ax2,hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hxMeas-hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),'xb');
                                scatter(ax2,hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),hyMeas-hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),'xr');
                            elseif chMask>=chMeas
                                scatter(ax2,pMask(1+chMask-chMeas:chMask-chMeas+length(pMeas)),pMeas-pMask(1+chMask-chMeas:chMask-chMeas+length(pMeas)),'og');
                                scatter(ax2,hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hxMeas-hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),'ob');
                                scatter(ax2,hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),hyMeas-hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),'or');
                            end
                        end
                        
                    end
                end
                
                sc = scatter(ax1,bwMasks(bwMasks~=0),bwMeas(bwMeas~=0),'xk');
                set(sc,'Tag','Beam Width : Mask - Measured');
                
                if resTest == 1
                    scatter(ax2,bwMasks(bwMasks~=0),bwMeas(bwMeas~=0)-bwMasks(bwMasks~=0),'xk');
                    xlabel(ax2,'Masks length [nm]');
                    ylabel(ax2,'\Delta L [nm]');
                end

                if i == 1
                        xlabel(ax1,'Mask Length [nm]');
                        ylabel(ax1,'Measured Length [nm]');
                end
             case 'All length : Curvature - Measured'
                nIm = length([imDataMat.imDose]~=0);

                set(ax1,'NextPlot','replacechildren');
                hold(ax1,'on');
                for kIm = 1:nIm
                    if imScl(kIm)~=0 && imData{kIm}.imPhCry>0
                        mask = fabMasks{imData{kIm}.imChip,imData{kIm}.imSample,imData{kIm}.imPhCry};
                        hxMask = mask.hx;
                        hyMask = mask.hy;
                        hMask = mask.hInd;
                        chMask = find(hMask==0);
                        ell = cell2mat(imData{kIm}.ellipses);

                        hxMeas  = 2*imScl(kIm)*[ell.a];
                        hyMeas  = 2*imScl(kIm)*[ell.b];
                        %curvX   = imScl(kIm)*[ell.a].*[ell.a]./[ell.b];
                        %curvY   = imScl(kIm)*[ell.b].*[ell.b]./[ell.a];
                        curvX   = (0.5*hyMask).^2./(0.5*hxMask);
                        curvY   = (0.5*hxMask).^2./(0.5*hyMask);

                        chMeas = find(hy(1+shArray(kIm):sh+length(hyMeas))==min(hy(1+shArray(kIm):sh+length(hyMeas))));
                        if imData{kIm}.imPhCry > 5 && chMask>=chMeas              
                            sc = scatter(ax1,curvX(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hxMeas,'xb');
                            %sc = scatter(ax1,curvX,hxMeas,'xb');
                            set(sc,'Tag','hy : Mask - Measured');
                            sc = scatter(ax1,curvY(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hyMeas,'xr');
                            %sc = scatter(ax1,curvY,hyMeas,'xr');
                            set(sc,'Tag','hy : Mask - Measured');
                        elseif chMask>=chMeas
                            sc = scatter(ax1,curvX(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hxMeas,'ob');
                            %sc = scatter(ax1,curvX,hxMeas,'ob');
                            set(sc,'Tag','hy : Mask - Measured');
                            sc = scatter(ax1,curvY(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hyMeas,'or');
                            %sc = scatter(ax1,curvY,hyMeas,'or');
                            set(sc,'Tag','hy : Mask - Measured');
                        end
                        if resTest == 1
                            hold(ax2,'on');
                            if imData{kIm}.imPhCry > 5
                                scatter(ax2,1./curvX(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hxMeas-hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),'xb');
                                scatter(ax2,1./curvY(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hyMeas-hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),'xr');
                                %scatter(ax2,curvX,hxMeas-hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),'xb');
                                %scatter(ax2,curvY,hyMeas-hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),'xr');
                            else
                                scatter(ax2,1./curvX(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hxMeas-hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),'ob');
                                scatter(ax2,1./curvY(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),hyMeas-hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),'or');
                                %scatter(ax2,curvX,hxMeas-hxMask(1+chMask-chMeas:chMask-chMeas+length(hxMeas)),'ob');
                                %scatter(ax2,curvY,hyMeas-hyMask(1+chMask-chMeas:chMask-chMeas+length(hyMeas)),'or');
                            end
                            xlabel(ax2,'Mask curvature [nm]');
                            ylabel(ax2,'\Delta L [nm]');
                        end

                    end
                end

                if i == 1
                        xlabel(ax1,'Mask curvature [nm]');
                        ylabel(ax1,'Measured Length [nm]');
                end
            otherwise
                write2commandHistory(handles,'This plot type was added but is unknown of the drawPlot() function. Please add this plot to the switch block in drawPlot');
        end
    end
    grid(ax1,'on');
    set(ax1,'FontSize',17);
    axis(ax1,'auto');
    if resTest==1
        grid(ax2,'on');
        set(ax2,'FontSize',17);
        axis(ax2,'auto');
    end
    highlightPlot(handles,imDataMat);
    
    if modelTest==1
        plotModel(handles);
    end
    close(h);
end