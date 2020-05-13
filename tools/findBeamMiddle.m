function p = findBeamMiddle(fittedHoles)

    % Data initialization
    n = length(fittedHoles);
    x = zeros(n,1);
    y = zeros(n,1);

    % Extraction of the centers coordinates
    for i = 1:n
        if isempty(fittedHoles{i}.X0_in)
            continue;
        end
        x(i) = fittedHoles{i}.X0_in;
        y(i) = fittedHoles{i}.Y0_in;
    end

    % Fitting a line along the holes centers
    p = polyfit(x,y,1);

end