function [Xm,Ym] = interpolateMassCenter(X,Y,Mx,My)
% Compute the mass center from the eight neighboring pixels
% Crop the image by one pixel one each side 
% Output is the 'mass' center coordinates (Xm,Ym)
% X and Y are the input coordinates and Mx, My the respective weights 
% used for the X and Y coordinates

[nx,ny] = size(X);

Mx = Mx + 1e-12*randn(nx,ny)+1;
My = My + 1e-12*randn(nx,ny)+1;
Xsum = zeros(nx-2,ny-2);
Ysum = zeros(nx-2,ny-2);
Mxsum = 1e-12*ones(nx-2,ny-2);
Mysum = 1e-12*ones(nx-2,ny-2);


for i = 1:3
    for j = 1:3
        Xsum = Xsum + X(i:end-3+i,j:end-3+j).*Mx(i:end-3+i,j:end-3+j);
        Ysum = Ysum + Y(i:end-3+i,j:end-3+j).*My(i:end-3+i,j:end-3+j);
        Mxsum = Mxsum + Mx(i:end-3+i,j:end-3+j);
        Mysum = Mysum + My(i:end-3+i,j:end-3+j);
    end
end

Xm = Xsum ./ Mxsum;
Ym = Ysum ./ Mysum;
%Xm(isnan(Xm)) = 0;
%Ym(isnan(Ym)) = 0;
end

