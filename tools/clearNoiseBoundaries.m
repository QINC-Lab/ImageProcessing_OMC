function boundariesOut = clearNoiseBoundaries(boundariesIn)
   
    %Remove small countours likely to be noise
    j = 1;
    for i = 1:length(boundariesIn)
        if length(boundariesIn{i})>22 %100 %60 %30 %50
            boundariesOut{j} = boundariesIn{i};
            j = j + 1;
        end
    end

end