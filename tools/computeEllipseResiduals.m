function [holesRoughness,xFit,yFit] = computeEllipseResiduals(paramEllipse,x,y,scl)
% Computes the deviation of data points from an ellipse curve. paramEllipse
% are the ellipse parameters, x and y the data cooridinates. The structure
% of paramEllipse is expected to have the form of the output from the
% fit_ellipse function

    % Coordinates of the ellipse center
    x0 = paramEllipse.X0_in;
    y0 = paramEllipse.Y0_in;
    
    % Ellipse's radiuses 
    a = paramEllipse.a;
    b = paramEllipse.b;
    
    % Shifting the coordinate system to the ellipse center
    xp = x-x0;
    yp = y-y0;
    
    % Applying the inverse rotation
    s = sin(paramEllipse.phi);
    c = cos(paramEllipse.phi);

    xpp = c*xp+s*yp;
    ypp = c*yp-s*xp;

    
    % Optimizing the angle t for the data points
    tOpt = zeros(size(x));
    for i = 1:length(tOpt)
        if xpp(i)>0
            tstart = atan(ypp(i)/xpp(i));
        elseif xpp(i)<0 
            tstart = pi + atan(ypp(i)/xpp(i));
        elseif xpp(i)==0 && ypp(i)<0
            tstart = -0.5*pi;
        elseif xpp(i)==0 && ypp(i)>0
            tstart = 0.5*pi;
        end
        tOpt(i) = fminsearch(@(t)(a*cos(t)-xpp(i))^2+(b*sin(t)-ypp(i))^2,tstart);
    end
    
    xFit = a*cos(tOpt);
    yFit = b*sin(tOpt);
    s = sin(paramEllipse.phi);
    c = cos(paramEllipse.phi);
    xFitp = c*xFit+s*yFit;
    yFitp = c*yFit-s*xFit;
    
    xFit = xFitp+x0;
    yFit = yFitp+y0;
    
    diff = hypot(xFit-x,yFit-y);
    %figure;plot(tOpt);

    % standard deviation in nm
    holesRoughness = diff(:);
end

