function [edgeTop,edgeBottom,edgeIntTop,edgeIntBottom,pTop,pBottom] = fitBeamEdges(beam,fittedHoles,intX,intY)

    % Defining the middle of the beam from the holes centers
    pBeamMiddle = findBeamMiddle(fittedHoles);
    
    % Divide the top and bottom egdes using the middle of the beam
%     edgeTop = beamEdges(beamEdges(:,1)<polyval(pBeamMiddle,beamEdges(:,2)),:);
%     edgeBottom = beamEdges(beamEdges(:,1)>polyval(pBeamMiddle,beamEdges(:,2)),:);
    edgeTop = beam(beam(:,1)<polyval(pBeamMiddle,beam(:,2)),:);
    edgeBottom = beam(beam(:,1)>polyval(pBeamMiddle,beam(:,2)),:);
    
    %  Remove small vertical edges on the sides
    XTop = edgeTop(:,2);
    YTop = edgeTop(:,1);
    XBot = edgeBottom(:,2);
    YBot = edgeBottom(:,1);
    diff = abs(XTop-mean(XTop(:)));
    Xm = XTop(diff==min(diff(:)));
    YmT = YTop(XTop==Xm(1))-pBeamMiddle(1)*Xm;
    YmB = YBot(XTop==Xm(1))-pBeamMiddle(1)*Xm;
    XTL = XTop(XTop<Xm(1));
    YTL = YTop(XTop<Xm(1));
    XTR = XTop(XTop>Xm(1));
    YTR = YTop(XTop>Xm(1));
    XBL = XBot(XBot<Xm(1));
    YBL = YBot(XBot<Xm(1));
    XBR = XBot(XBot>Xm(1));
    YBR = YBot(XBot>Xm(1));
    
    dYTL = abs(YTL-polyval([pBeamMiddle(1),YmT(1)],XTL));
    dYTR = abs(YTR-polyval([pBeamMiddle(1),YmT(1)],XTR));
    limTL = max(XTL(dYTL>0.2*(abs(pBeamMiddle(2)-YmT(1)))));
    limTR = max(XTR(dYTR>0.2*(abs(pBeamMiddle(2)-YmT(1)))));
    
    dYBL = abs(YBL-polyval([pBeamMiddle(1),YmB(1)],XBL));
    dYBR = abs(YBR-polyval([pBeamMiddle(1),YmB(1)],XBR));
    limBL = max(XBL(dYBL>0.2*(abs(pBeamMiddle(2)-YmB(1)))));
    limBR = max(XBR(dYBR>0.2*(abs(pBeamMiddle(2)-YmB(1)))));
    
    limR = min(limBR,limTR);
    limL = max(limBL,limTL);
    
    if isempty(limR) 
        limR = mean(max(XBot(:)));
    end
    if isempty(limL) 
        limL = mean(min(XBot(:)));
    end
    
    edgeTop = edgeTop(and(edgeTop(:,2)>limL+1,edgeTop(:,2)<limR-1),:);
    edgeBottom = edgeBottom(and(edgeBottom(:,2)>limL+1,edgeBottom(:,2)<limR-1),:);
%     beamEdges = beam(and(beam(:,2)>min(beam(:,2))+1,beam(:,2)<max(beam(:,2))-1),:); % + and -1 because of the cropping due to the gradient
    
    % Interpolation of the beam edges
    intEdgeTopX = diag(intX(edgeTop(:,1)-2,edgeTop(:,2)-2)); % -2 factor due to the cropping from the gradient and the interpolation
    intEdgeTopY = diag(intY(edgeTop(:,1)-2,edgeTop(:,2)-2));
    intEdgeBottomX = diag(intX(edgeBottom(:,1)-2,edgeBottom(:,2)-2));
    intEdgeBottomY = diag(intY(edgeBottom(:,1)-2,edgeBottom(:,2)-2));

    % Fitting straight lines
    pTop = polyfit(intEdgeTopX,intEdgeTopY,1);
    %pTopRaw = polyfit(topEdge(:,2),topEdge(:,1),1);
    pBottom = polyfit(intEdgeBottomX,intEdgeBottomY,1);

    % Return the interpolated edges
    % Initialization
    edgeIntTop = edgeTop;
    edgeIntBottom = edgeBottom;
    edgeIntTop(:,2) = intEdgeTopX;
    edgeIntTop(:,1) = intEdgeTopY;
    edgeIntBottom(:,2) = intEdgeBottomX;
    edgeIntBottom(:,1) = intEdgeBottomY;

    
end