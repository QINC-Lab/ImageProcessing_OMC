function imOut = imCropX(imIn)
    
    [Nx,~] = size(imIn);
    
    % Computing the standard deviation of every image row
    imStd = zeros(Nx,1);
    for i = 1:Nx
        imStd(i) = std(double(imIn(i,:)));
    end
    
    % Normalization of the standard deviation
    imStd = imStd/max(imStd(:));

    [pks,locPks] = findpeaks(imStd,linspace(1,Nx,Nx),'MinPeakHeight',0.8,'MinPeakDistance',round(0.6*Nx));
    
    % If a high intensity region is found (likely the beam)
    if isempty(pks)==0
        
        % location of the beam (high intensity region)
        xIndPk = locPks(pks==max(pks(:)));
        
        % Initialization of the cropping indices
        xIndLeft = xIndPk;
        xIndRight = xIndPk;
        
        offset = round(0.2*Nx);
        
        % Moving out of the high intesity region progressively
        while xIndLeft>offset && mean(imStd(xIndLeft-30:xIndLeft))>0.3
            xIndLeft = xIndLeft - 30;
        end
        
        % Adding more background to have a big enough peak for the
        % threholding after
        if xIndLeft>offset
            xIndLeft = xIndLeft -offset;
        else 
            xIndLeft = 1;
        end
        
        % The same for the lower bound of the image (top->1 bottom->Nx)
        while xIndRight<Nx-offset && mean(imStd(xIndRight:xIndRight+30))>0.3
            xIndRight = xIndRight + 30;
        end
        if xIndRight<Nx-offset;
            xIndRight = xIndRight + offset;
        else
            xIndRight = Nx;
        end
    
    % If no high intensity region   
    else
        xIndLeft = 1;
        xIndRight = Nx;
    end
    
    % Cropping along the height
    imOut = imIn(xIndLeft:xIndRight,:);

end