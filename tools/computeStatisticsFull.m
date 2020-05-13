function computeStatisticsFull(handles)
    h = waitbar(0,'Compute...');
    OSvalue = get(handles.OSbuttongroup.SelectedObject,'String');
    if strcmp(OSvalue,'Windows')==1
        fSep = '\';
    elseif strcmp(OSvalue,'UNIX')==1
        fSep = '/';
    end
    load(strcat(get(handles.imFolder,'String'),fSep,'imData.mat'));
    
    nIm = length(imData);
    
    [shArray,chArray] = findHolePosition(handles);
    
    [hx,hy,p,bw] = getModelValues();
    
    chModel = find(hy==min(hy(:)));
    xAxis = linspace(1,length(hx),length(hx))-chModel;

    nCorrection = 6;

    correction = zeros(nIm,1);
    
    hxSet = zeros(length(hx),nIm,nCorrection);
    hySet = zeros(length(hx),nIm,nCorrection);
    pSet = zeros(length(hx)-1,nIm,nCorrection);
   
    hxSet(:) = nan;
    hySet(:) = nan;
    pSet(:) = nan;
    
    bwM = mean(bw(bw~=0));
    
    % Loop over the images
    for i = 1:nIm
        
        if imData{i}.imDose~=0 
            sh = shArray(i);
            ch = chArray(i);
            scl = imData{i}.imScale;
            
            cavityNumber = str2double(imData{i}.imName(end-5:end-4));
%            if cavityNumber <=5
%                correction(i) = 1;
%            elseif cavityNumber <=12
%                correction(i) = 2;
%            elseif cavityNumber <=19
%                correction(i) = 3;
%            elseif cavityNumber <=26
%                correction(i) = 4;
%             elseif cavityNumber <=33
%                 correction(i) = 5;
%             else
%                 correction(i) = 6;
%             end
            if cavityNumber <=20
                correction(i) = 1;
            elseif cavityNumber <=40
                correction(i) = 2;
%             elseif cavityNumber <=19
%                 correction(i) = 3;
%             elseif cavityNumber <=26
%                 correction(i) = 4;
%             elseif cavityNumber <=33
%                 correction(i) = 5;
%             else
%                 correction(i) = 6;
            end

            ell = imData{i}.ellipses;
            ellM = cell2mat(ell);
            x = linspace(1-ch+sh,length(ell)-ch+sh,length(ell));
            sAx = [ellM.b]*2*scl;
            lAx = [ellM.a]*2*scl;
            pit = zeros(length(ell)-1,1);
            for j = 1:length(pit)
                pit(j) = scl*hypot( ell{j}.X0_in-ell{j+1}.X0_in , ell{j}.Y0_in-ell{j+1}.Y0_in );
            end
            
            hxSet(x+chModel,i,correction(i)) = lAx'-hx(x+chModel);
            hySet(x+chModel,i,correction(i)) = sAx'-hy(x+chModel);
            pSet(x(1:end-1)+chModel,i,correction(i)) = pit-p(x(1:end-1)+chModel);
            
            
        end
        
        

                        
    end
    
    hxMean = zeros(length(hx),nCorrection);
    hxMean(:) = nan;
    hxStdv = zeros(length(hx),nCorrection);
    hxStdv(:) = nan;
    hyMean = zeros(length(hy),nCorrection);
    hyMean(:) = nan;
    hyStdv = zeros(length(hy),nCorrection);
    hyStdv(:) = nan;
    pMean = zeros(length(hx)-1,nCorrection);
    pMean(:) = nan;
    pStdv = zeros(length(hx)-1,nCorrection);
    pStdv(:) = nan;
    
    for iCorrection = 1:nCorrection
        for i = 1:length(hx)
            tempInd = ~isnan(hxSet(i,:,iCorrection));
            tempVar = hxSet(i,tempInd,iCorrection);
            hxMean(i,iCorrection) = mean(tempVar(:));
            hxStdv(i,iCorrection) = std(tempVar(:));
            tempInd = ~isnan(hySet(i,:,iCorrection));
            tempVar = hySet(i,tempInd,iCorrection);
            hyMean(i,iCorrection) = mean(tempVar(:));
            hyStdv(i,iCorrection) = std(tempVar(:));
            if i<length(hx)
                tempInd = ~isnan(pSet(i,:,iCorrection));
                tempVar = pSet(i,tempInd,iCorrection);
                pMean(i,iCorrection) = mean(tempVar(:));
                pStdv(i,iCorrection) = std(tempVar(:));
            end
        end
    end
    
    f1 = figure;
    f2 = figure;

    for iCorrection = 1:nCorrection
        if iCorrection==1
            figure(f1);
        elseif iCorrection==2
            figure(f2);
        end
        xAxisT = xAxis(~isnan(hxMean(:,iCorrection)));
        errorbar(xAxisT,hxMean(~isnan(hxMean(:,iCorrection)),iCorrection),hxStdv(~isnan(hxMean(:,iCorrection)),iCorrection),'+b','LineStyle','-');
        hold on;
        errorbar(xAxisT,hyMean(~isnan(hxMean(:,iCorrection)),iCorrection),hyStdv(~isnan(hxMean(:,iCorrection)),iCorrection),'+r','LineStyle','-');
        errorbar(xAxisT(1:end-1)+0.5,pMean(~isnan(pMean(:,iCorrection)),iCorrection),pStdv(~isnan(pMean(:,iCorrection)),iCorrection),'+g','LineStyle','-');
    end
    figure(f1);
    xlabel('Hole index');
    ylabel('<\Delta L>');
    grid on;
    set(gca,'FontSize',12);
    title('Uncorrected design (C=0)');
    legend('h_x','h_y','p','Orientation','horizontal','Location','Best');
    set(gca,'FontSize',12);

    figure(f2);
    xlabel('Hole index');
    ylabel('<\Delta L>');
    grid on;
    title('Corrected design (C=50 [nm])');
    legend('h_x','h_y','p','Orientation','horizontal','Location','Best');
    set(gca,'FontSize',12);
    
%     figure(f1);
%     subplot(2,1,1);
%     xlabel('Hole index');
%     ylabel('<\Delta L>');
%     grid on;
%     set(gca,'FontSize',12);
%     title('Uncorrected design (C=0)');
%     legend('h_x','h_y','p','Orientation','horizontal','Location','Best');
%     subplot(2,1,2);
%     xlabel('Hole index');
%     ylabel('<\Delta L>');
%     grid on;
%     title('Corrected design (C=50 [nm])');
%     legend('h_x','h_y','p','Orientation','horizontal','Location','Best');
%     set(gca,'FontSize',12);
    
%     figure(f2);
%     subplot(2,1,1);
%     xlabel('Hole index');
%     ylabel('<\Delta L>');
%     grid on;
%     set(gca,'FontSize',12);
%     title('Corrected design (C=45 [nm])');
%     legend('h_x','h_y','p','Orientation','horizontal','Location','Best');
%     subplot(2,1,2);
%     xlabel('Hole index');
%     ylabel('<\Delta L>');
%     grid on;
%     title('Corrected design (C=50 [nm])');
%     legend('h_x','h_y','p','Orientation','horizontal','Location','Best');
%     set(gca,'FontSize',12);
%  
end















% function computeStatistics(handles)
%     h = waitbar(0,'Compute...');
%     OSvalue = get(handles.OSbuttongroup.SelectedObject,'String');
%     if strcmp(OSvalue,'Windows')==1
%         fSep = '\';
%     elseif strcmp(OSvalue,'UNIX')==1
%         fSep = '/';
%     end
%     load(strcat(get(handles.imFolder,'String'),fSep,'imData.mat'));
%     
%     nIm = length(imData);
%     
%     [shArray,chArray] = findHolePosition(handles);
%     
%     [hx,hy,p,bw] = getModelValues();
%     
%     chModel = find(hy==min(hy(:)));
%     xAxis = linspace(1,length(hx),length(hx))-chModel;
%     
%     nChip = 2;
%     nSample = 2;
%     nCorrection = 2;
%     
%     chip = zeros(nIm,1);
%     sample = zeros(nIm,1);
%     correction = zeros(nIm,1);
%     
%     hxSet = zeros(length(hx),nIm,nChip,nSample,nCorrection);
%     hySet = zeros(length(hx),nIm,nChip,nSample,nCorrection);
%     pSet = zeros(length(hx),nIm,nChip,nSample,nCorrection);
%     
%     hxSet(:) = nan;
%     hySet(:) = nan;
%     pSet(:) = nan;
%     
%     bwM = mean(bw(bw~=0));
%     
%     % Loop over the images
%     for i = 1:nIm
%         
%         if imData{i}.imDose~=0 
%             sh = shArray(i);
%             ch = chArray(i);
%             scl = imData{i}.imScale;
%             
%             cavityNumber = str2double(imData{i}.imName(end-5:end-4));
%             if cavityNumber <20
%                 correction(i) = 1;
%             else
%                 correction(i) = 2;
%             end
%             if ~isempty(strfind(imData{i}.imName,'155_1'))
%                 chip(i) = 1;
%             else
%                 chip(i) = 2;
%             end
%             if ~isempty(strfind(imData{i}.imName,'A_'))
%                 sample(i) = 1;
%             else
%                 sample(i) = 2;
%             end
% 
%             ell = imData{i}.ellipses;
%             ellM = cell2mat(ell);
%             x = linspace(1-ch+sh,length(ell)-ch+sh,length(ell));
%             sAx = [ellM.b]*2*scl;
%             lAx = [ellM.a]*2*scl;
%             pit = zeros(length(ell)-1,1);
%             for j = 1:length(pit)
%                 pit(j) = scl*hypot( ell{j}.X0_in-ell{j+1}.X0_in , ell{j}.Y0_in-ell{j+1}.Y0_in );
%             end
%             
%             hxSet(x+chModel,i,chip(i),sample(i),correction(i)) = lAx'-hx(x+chModel);
%             hySet(x+chModel,i,chip(i),sample(i),correction(i)) = sAx'-hy(x+chModel);
%             pSet(x(1:end-1)+chModel,i,chip(i),sample(i),correction(i)) = pit;
%             
%             
%         end
%         
%         
% 
%                         
%     end
%     
%     hxMean = zeros(length(hx),nChip,nSample,nCorrection);
%     hxMean(:) = nan;
%     hxStdv = zeros(length(hx),nChip,nSample,nCorrection);
%     hxStdv(:) = nan;
%     hyMean = zeros(length(hy),nChip,nSample,nCorrection);
%     hyMean(:) = nan;
%     hyStdv = zeros(length(hy),nChip,nSample,nCorrection);
%     hyStdv(:) = nan;
%     
%     for iChip = 1:nChip
%         for iSample = 1:nSample
%             for iCorrection = 1:nCorrection
%                 for i = 1:length(hx)
%                     hxMean(i,iChip,iSample,iCorrection) = mean(hxSet(i,~isnan(hxSet(i,:,iChip,iSample,iCorrection)),iChip,iSample,iCorrection));
%                     hxStdv(i,iChip,iSample,iCorrection) = std(hxSet(i,~isnan(hxSet(i,:,iChip,iSample,iCorrection)),iChip,iSample,iCorrection));
%                     hyMean(i,iChip,iSample,iCorrection) = mean(hySet(i,~isnan(hySet(i,:,iChip,iSample,iCorrection)),iChip,iSample,iCorrection));
%                     hyStdv(i,iChip,iSample,iCorrection) = std(hySet(i,~isnan(hySet(i,:,iChip,iSample,iCorrection)),iChip,iSample,iCorrection));
%                 end
%             end
%         end
%     end
%     
%     figure;
%     
%     for iChip = 1:nChip
%         for iSample = 1:nSample
%             for iCorrection = 1:nCorrection
%                 if iCorrection==1
%                     col = 'r';
%                 else
%                     col = 'b';
%                 end
%                 errorbar(xAxis,hxMean(:,iChip,iSample,iCorrection),hxStdv(:,iChip,iSample,iCorrection),col,'LineStyle','-','Marker','x');
%                 hold on;
%                 errorbar(xAxis,hyMean(:,iChip,iSample,iCorrection),hyStdv(:,iChip,iSample,iCorrection),col,'LineStyle','-','Marker','+');
%             end
%         end
%     end
%     set(gca,'FontSize',17);
%     xlabel('Hole index');
%     ylabel('<\Delta L>');
%     grid on;
%     close(h);
% end