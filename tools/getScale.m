function scl = getScale(handles)

    if exist('imData','var')~=1
        load(strcat(handles.imFullPath,'imData.mat'));
    end
    
    nIm = length(imData);
    
    [sh,ch] = findHolePosition(handles,imData);
    
    [~,hy,pP,~] = getModelValues();
    
    chP = find(hy==min(hy(:)));
    
    
    % Correct the image scale with the pitch
    for i = 1:nIm
        chM = ch(i);
        shM = sh(i);
        ell = cell2mat(imData{i}.ellipses);
        xCen = [ell.X0_in];
        yCen = [ell.Y0_in];
        imScl = imData{i}.imScale;
        pMeas  = hypot(xCen(2:end)-xCen(1:end-1),yCen(2:end)-yCen(1:end-1));
        save('bin.mat','chP','chM','shM','pP')
        a = 1.2;
        imSclNew = fminsearch(@(pMeas) diff(pMeas,a),imScl);
        delete('bin.mat');
        imData{i}.imScale = imSclNew;
    end
    save(strcat(handles.imFullPath,'imData.mat'),'imData');    

end

function imSclNew = diff(pMeas,a)
    load('bin.mat');
    imSclNew = a*pMeas'-pP(chP-(chM-shM)-1:chM+(chM-shM));
end







% % % First estimate of the scale provided by the SEM that will be
% % % corrected using the pitch later
% % fid = fopen(imPath);
% % t = textscan(fid,'%c');
% % t = t{1};
% % pos = strfind(t','ImagePixelSize');
% % 
% % scl = str2double(t(pos+15:pos+19)');
% % if strcmp(t(pos+20:pos+21)','nm')
% %     
% % elseif strcmp(t(pos+20:pos+21)','pm')
% %     scl = 0.001*scl;
% %     
% % else
% %     scl = 1000*scl;
% % end
% % if isnan(scl)
% %     scl = 4;
% % end
% % end