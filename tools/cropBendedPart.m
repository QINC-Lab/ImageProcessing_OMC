function [beam] = cropBendedPart(beam,fittedHoles)

    % Extract X coordinate of the holes centers and the long axis
    % initialization
    n = length(fittedHoles);
    x = zeros(n,1);
    a = zeros(n,1);

    % Extraction of the centers coordinates
    for i = 1:n
        if isempty(fittedHoles{i}.X0_in)
            x(i) = NaN;
            a(i) = NaN;
            continue;
        end
        x(i) = fittedHoles{i}.X0_in;
        a(i) = fittedHoles{i}.long_axis;
    end

    % X coordinate of the left and right holes
    minXHoles = min(x(:));
    maxXHoles = max(x(:));

    aLeft = a(x==minXHoles);
    aRight = a(x==maxXHoles);
    
    % Cutting the beam if needed
    if minXHoles-aLeft>min(beam(:,2))
        beam = beam(beam(:,2)>minXHoles-aLeft,:);
    end
    if maxXHoles+aRight<max(beam(:,2))
        beam = beam(beam(:,2)<maxXHoles+aRight,:);
    end

end