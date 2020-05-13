function [fittedHoles,holesInt] = fitHoles(holes,intX,intY)

    % Fiiting ellipses on the holes using the interpolated edges
    [ny,nx] = size(intX);
    j = 1;

    % Initialization interpolated edges
    fittedHoles = {};
    
    % Loop over the holes
    for i=1:length(holes)
        holesY = holes{i}(:,1);
        holesX = holes{i}(:,2);
        % Making sur that the holes is inside an allowed region of the
        % image
        if max(holesX)<nx && min(holesX)>2 && max(holesY)<ny && min(holesY)>2
            % Interpolated edges
            holesIntX = diag(intX(holesY-2,holesX-2)); % -2 factor due to the cropping from the gradient and the interpolation
            holesIntY = diag(intY(holesY-2,holesX-2));

            holesInt{j}(:,1) = holesIntY;
            holesInt{j}(:,2) = holesIntX;
            holesInt{j} = holes{j};

            fittedHoles{j} = fit_ellipse(holesIntX,holesIntY);
            j = j+1;
        else
            disp(['Hole ',num2str(i),' is not within range']);
%             emptystruct = struct( ...
%                 'a',[],...
%                 'b',[],...
%                 'phi',[],...
%                 'X0',[],...
%                 'Y0',[],...
%                 'X0_in',[],...
%                 'Y0_in',[],...
%                 'long_axis',[],...
%                 'short_axis',[],...
%                 'status','Holes out ot range' );
%             fittedHoles{j} = emptystruct; % Empty structure cus hole is out of range
			continue;
        end
    end

end