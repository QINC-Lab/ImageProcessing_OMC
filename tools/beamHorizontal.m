function imOut = beamHorizontal(imIn)

    % Taking two image slice one vertical one horizontal. The direction
    % where the beam is should have the biggest standard deviation
    s1 = imIn(:,40);
    s2 = imIn(140,:);

    % If vertical rotation by 90
    if std(double(s1))<std(double(s2))
        imOut = uint8(rot90(imIn));
		
    else
        imOut = imIn;
    end

end