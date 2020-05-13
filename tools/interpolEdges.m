function [intX,intY] = interpolEdges(im)

    % Interpolation of the edge points
    % Shifted duplication of the image
    Ixm1 = double(im(1:end-2,2:end-1));
    Ixp1 = double(im(3:end,2:end-1));
    Iym1 = double(im(2:end-1,1:end-2));
    Iyp1 = double(im(2:end-1,3:end));

    % Computation of the directional gradients
    Gx = 0.5*abs(Ixp1-Ixm1);
    Gy = 0.5*abs(Iyp1-Iym1);

    % Interpolate the 'mass' center coordinate couples of the gradient map
    [ny,nx] = size(im);
    [Xcoord,Ycoord] = meshgrid(2:nx-1,2:ny-1); % From 2 to end-1 because of the cropping due to the gradient

    
    [intX,intY] = interpolateMassCenter(Xcoord,Ycoord,Gx,Gy);
    
    % For DESIGN IMAGES UNCOMMENT
%     intX = Xcoord;
%     intY = Ycoord;

end