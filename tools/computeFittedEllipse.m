function fittedEllipse = computeFittedEllipse(paramEllipse,x,y)
% Computes the deviation of data points from an ellipse curve. paramEllipse
% are the ellipse parameters, x and y the data cooridinates. The structure
% of paramEllipse is expected to have the form of the output from the
% fit_ellipse function

    fittedEllipse = zeros(length(x),2);
    
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
        tOpt(i) = fminsearch(@(t)(a*cos(t)-xpp(i))^2+(b*sin(t)-ypp(i))^2,0.1);
    end
    
    x_elli = a*cos(tOpt);
    y_elli = b*sin(tOpt);
    
    % Rotate back;
    s = sin(-paramEllipse.phi);
    c = cos(-paramEllipse.phi);
    x_elli_p = c*x_elli+s*y_elli;
    y_elli_p = c*y_elli-s*y_elli;
    
    % Shift back
    x_elli = x_elli_p + x0;
    y_elli = y_elli_p + y0;
    
    fittedEllipse(:,1) = x_elli;
    fittedEllipse(:,2) = y_elli;
end

