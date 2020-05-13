function highlightPlot(handles,imDataMat)
    % Color
    r = [1 0 0];
    b = [0 0 1];
    
    pltList = get(handles.plotShownListbox,'String');
    nPlt  = length(pltList);
    
    ax = handles.imPlot;
    
    for i = 1:nPlt
        switch pltList{i}     
%             case 'p : Mask - Measured';
%                 sc = findobj(ax,'Tag',pltList{i});
%                 pMask = sc.XData;
%                 indIm = sc.UserData.indIm;
%                 indHole = sc.UserData.indHole;
%                 ind = get(handles.imSelPopUpMenu,'Value');
%                 ptsColor = zeros(length(pMask),3);
%                 ptsColor(:,3) = 1;
%                 if sum(and(indIm==ind,indHole==sc.UserData.selHole))>0
%                     ptsColor(and(indIm==ind,indHole==sc.UserData.selHole),:) = r;
%                 end
%                 set(sc,'CData',ptsColor);
%             
%             case 'hx : Mask - Measured';
%                 sc = findobj(ax,'Tag',pltList{i});
%                 hxMask = sc.XData;
%                 indIm = sc.UserData.indIm;
%                 indHole = sc.UserData.indHole;
%                 ind = get(handles.imSelPopUpMenu,'Value');
%                 ptsColor = zeros(length(hxMask),3);
%                 ptsColor(:,3) = 1;
%                 if sum(and(indIm==ind,indHole==sc.UserData.selHole))>0
%                     ptsColor(and(indIm==ind,indHole==sc.UserData.selHole),:) = r;
%                 end
%                 set(sc,'CData',ptsColor);
%                 
%             case 'hy : Mask - Measured';
%                 sc = findobj(ax,'Tag',pltList{i});
%                 hyMask = sc.XData;
%                 indIm = sc.UserData.indIm;
%                 indHole = sc.UserData.indHole;
%                 ind = get(handles.imSelPopUpMenu,'Value');
%                 ptsColor = zeros(length(hyMask),3);
%                 ptsColor(:,3) = 1;
%                 if sum(and(indIm==ind,indHole==sc.UserData.selHole))>0
%                     ptsColor(and(indIm==ind,indHole==sc.UserData.selHole),:) = r;
%                 end
%                 set(sc,'CData',ptsColor);
%                 
%             case 'Beam Width : Mask - Measured'
%                 sc = findobj(ax,'Tag',pltList{i});
%                 bwMask = sc.XData;
%                 indIm = sc.UserData.indIm;
%                 ind = get(handles.imSelPopUpMenu,'Value');
%                 ptsColor = zeros(length(bwMask),3);
%                 ptsColor(:,3) = 1;
%                 ptsColor(indIm==ind,:) = r;
%                 set(sc,'CData',ptsColor);
            otherwise
                %write2commandHistory(handles,'This plot type was added but is unknown of the highlightPlot() function. Please add this plot to the switch block in highlightPlot');
        end
    end
    


end