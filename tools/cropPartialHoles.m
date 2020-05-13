function imOut = cropPartialHoles(imIn)

    [Nx,Ny] = size(imIn);
    
    % Initialization of the while loops conditions
    partialHolesLeft = 1;
    partialHolesRight = 1;
    i = 1;
    j = Ny;
    while partialHolesLeft == 1
        if i+10<Ny
            s = sum(double(imIn(:,i:i+9)),2);

            % Normalization
            s = s - min(s(:));
            s = s/max(s(:));
            s2 = smooth(s,10);
            [pks,~] = findpeaks(s2,linspace(1,Nx,Nx),'MinPeakHeight',0.6,'MinPeakDistance',round(0.08*Nx),'MinPeakProminence',0.55);

            % If only one peaks is detected it is likely that no holes is there
            if length(pks)==1
                partialHolesLeft = 0;
                if i>1
                    i = i + 10;
                end
            end
            i = i + 10;
        else
            partialHolesLeft = 0;
        end
    end

    while partialHolesRight == 1
        if j-10>0
            % Same idea for the other side
            s = sum(double(imIn(:,j-9:j)),2);
            % Normalization
            s = s - min(s(:));
            s = s/max(s(:));
            s2 = smooth(s,10);
            [pks,~] = findpeaks(s2,linspace(1,Nx,Nx),'MinPeakHeight',0.6,'MinPeakDistance',round(0.08*Nx),'MinPeakProminence',0.55);

            % If only one peaks is detected it is likely that no holes is there
            if length(pks)==1
                partialHolesRight = 0;
                if j<Ny
                    j = j - 10;
                end
            end
            j = j - 10;
        else
            partialHolesRight = 0;
        end
    end
    if i-10>0 && j+10<=Ny
        imOut = imIn(:,i-10:j+10);
    else
        imOut = imIn;
    end

end