function [mRough,holesFit] = computeRoughness(edgeTop,edgeBottom,pTop,pBottom,holesInt,fittedHoles,scl)

    % Beam roughess
    % Difference times the image scale 
    % => gives the mean deviation in nm
    diffTop = edgeTop(:,1)-polyval(pTop,edgeTop(:,2));
    diffBottom = edgeBottom(:,1)-polyval(pBottom,edgeBottom(:,2));
    
    diffTot = cat(1,diffTop,diffBottom);

    % Holes Roughness
    n = length(holesInt);
    holesFit = holesInt;
    for i = 1:n
        if isempty(fittedHoles{i}.X0_in)
            continue;
        end
        [holeDiff,holesFitX,holesFitY] = computeEllipseResiduals(fittedHoles{i},holesInt{i}(:,2),holesInt{i}(:,1),scl);
        diffTot = cat(1,diffTot,holeDiff);
        % Scaling by the beam hight
        holesFit{i}(:,2)=holesFitY;
        holesFit{i}(:,1)=holesFitX;
    end

    % Average the difference over the beam and the holes and square to have
    % the "<x^2>" proportionnal to the roughness
    mRough = var(scl*diffTot(:));

end