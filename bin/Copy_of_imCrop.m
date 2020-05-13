function imCropped = imCrop(imIn)
% Crop the background from the beam photonic craystal images without
% banners. It takes three image sections and find the beam by assuming that
% the relevant feature is brither than the background.
    
    [Nx,Ny] = size(imIn);
    
    % Crop the image CMi banner at the bottom
    nCut = round(0.9*Nx);
    imIn = imIn(1:nCut,:);
    
    s1 = imIn(:,10);
    s2 = imIn(:,round(0.5*Ny));
    s3 = imIn(:,end-10);
    
    s4 = imIn(10,:);
    s5 = imIn(round(0.5*Ny),:);
    s6 = imIn(end-10,:);

    if std(double(s1))<std(double(s4))
        imIn = uint8(rot90(imIn));
        s = [s4' s5' s6'];
    else
        s = [s1 s2 s3];
    end
    m = zeros(3,1);
    M = zeros(3,1);
    
    for i = 1:3
        imThr = 0.9*(max(s(:,i))-min(s(:,i)));
        imInd = find(s(:,i)>imThr);
        m(i) = min(imInd(:));
        M(i) = max(imInd(:));
    end
    
    imMin = min(m(:));
    imMax = max(M(:));
    if imMin>100 && imMax<Ny-100
        imCropped = imIn(imMin-100:imMax+100,:);
    else
        imCropped = imIn(1:end,:);
    end
    figure;imshow(imCropped);
end