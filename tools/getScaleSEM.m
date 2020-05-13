function scl = getScaleSEM(imPath)
    
%     % Painter values
%     [~,hyP,pP,~] = getModelValues();
%     
%     % Central hole position of the Painter design
%     ch = find(hyP==min(hyP(:)));
%     
%     % Computing the pitch for the measured data using the pitch of the
%     % fitted elipses
%     nMeas  = length(fittedHoles)-1;
%     interval = zeros(1,nMeas);
%     for i=1:length(fittedHoles)
%     if isempty(fieldnames(fittedHoles{i}))
%         
%     end
%     end
%     fittedHolesM = cell2mat(fittedHoles);
%     xCen = [fittedHolesM.X0_in];
%     yCen = [fittedHolesM.Y0_in];
%     
%     for j = 1:nMeas
%         interval(j) = hypot(xCen(j)-xCen(j+1),yCen(j)-yCen(j+1));
%     end
%     
%     nModel = length(pP);
%     
%     % First approximation of the scale from the SEM meta data
%     fid = fopen(imPath);
%     t = textscan(fid,'%c');
%     t = t{1};
%     pos = strfind(t','ImagePixelSize');
% 
%     scl = str2double(t(pos+15:pos+19)');
%     if strcmp(t(pos+20:pos+21)','nm')
% 
%     elseif strcmp(t(pos+20:pos+21)','pm')
%         scl = 0.001*scl;
% 
%     else
%         scl = 1000*scl;
%     end
%     if isnan(scl)
%         scl = 4;
%     end
%     
%     k = 1;
%     while k+nMeas<=nModel
%         diff = sum(abs(scl*interval'-pP(k:k+nMeas-1)));
%         if k~=1
%             if minDiff>diff
%                 minDiff = diff;
%                 indMin = k;
%             end
%         else
%             minDiff = diff;
%             indMin = 1;
%         end     
%         k=k+1;
%     end
%     sh = indMin-1;
%     
%     scl = lsqcurvefit(@sclOptimization,scl,interval,pP(1+sh:sh+nMeas));


% end
            










% % % First estimate of the scale provided by the SEM that will be
% % % corrected using the pitch later
fid = fopen(imPath);
t = textscan(fid,'%c');
t = t{1};
pos = strfind(t','ImagePixelSize');

scl = str2double(t(pos+15:pos+19)');
if strcmp(t(pos+20:pos+21)','nm')
    
elseif strcmp(t(pos+20:pos+21)','pm')
    scl = 0.001*scl;
    
else
    scl = 1000*scl;
end
if isnan(scl)
    scl = 4;
end
end