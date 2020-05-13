function [sh,ch] = findHolePosition(handles,imData)
    % sh : shift of the hole index to match the model with the measures
    % ch : central holes position to set it at 0
    if nargin < 2
        load(strcat(handles.imFullPath,'imData.mat'));
    end
    nIm = length(imData);
    
    sh = zeros(nIm,1);
    ch = zeros(nIm,1);
    
    for i = 1:nIm
        if imData{i}.imDose~=0
            el = cell2mat([imData{i}.ellipses]);
            interval = zeros(1,length(el)-1);
            for j = 1:length(el)-1
                interval(j) = imData{i}.imScale*hypot(el(j).X0_in-el(j+1).X0_in,el(j).Y0_in-el(j+1).Y0_in);
            end
            [~,hy,d,~] = getModelValues();

            nModel = length(d);
            nMeas  = length(interval);
            
            k = 1;
            while k+nMeas<=nModel
                diff = sum(abs(interval'-d(k:k+nMeas-1)));
                if k~=1
                    if minDiff>diff
                        minDiff = diff;
                        indMin = k;
                    end
                else
                    minDiff = diff;
                    indMin = 1;
                end     
                k=k+1;
            end
            sh(i) = indMin-1;
            ch(i) = find(hy==min(hy(:)));
        end
    end

end