%% Analysis
%import Data first
clc
clear all
folder='\\lpqm1srv3.epfl.ch\Nano\DAQsoftware\Image processing\C614_155\Chip1A\'
load([folder,'imData'])
%%
close all
%BeamWidth
nSEM = length(imData);
Design_Hx    = [99.50,99.10,97.50, 94.65, 90.93, 87.26, 84.48, 82.90, 82.5, 82.5, 82.5, 82.5, 82.5, 82.5,82.5,82.5, 82.5, 82.5];
Design_Hy    = [85.00,87.04,95.01,109.51,129.52,151.16,169.16,180.08,183.0,183.0,183.0,183.0,183.0,183,183,183,183,183,183,183];


for iSEM = 1:nSEM
    if imData{iSEM}.imDose~=0
        el = cell2mat([imData{iSEM}.ellipses]);
        interval = zeros(1,length(el)-1);
        for j = 1:length(el)-1
            interval(j) = imData{iSEM}.imScale*hypot(el(j).X0_in-el(j+1).X0_in,el(j).Y0_in-el(j+1).Y0_in);
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
        sh = indMin-1;
        chMod = find(hy==min(hy(:)));
        ch(iSEM) = chMod-sh;
    end
    nC(iSEM) = imData{iSEM}.imPhCry;
    ell = cell2mat(imData{iSEM}.ellipses);
    holesIndex= linspace(1,length(ell),length(ell))-ch(iSEM);
    Painter_Hx=Design_Hx(abs(holesIndex)+1);
    Painter_Hy=Design_Hy(abs(holesIndex)+1);
    imScl= imData{iSEM}.imScale;
    hxMeas  = imScl*[ell.a];
    hyMeas  = imScl*[ell.b];
    
    figure(1)
    hold on
    plot(holesIndex,hxMeas);
    plot(holesIndex,hyMeas);
    hold off
    figure(2)
    hold on
    plot(holesIndex,hxMeas-Painter_Hx);
    plot(holesIndex,hyMeas-Painter_Hy);
    hold off
end
    figure(1)
    xlabel('Holes Index')
    ylabel('Measured hx hy')
    figure(2)
    xlabel('Holes Index')
    ylabel('Difference between the Measured hx hy and the design')
    
%%
figure(3)
hold on
for i=1:nSEM
scatter(imData{1,i}.imPhCry,imData{1,i}.beamWidth,'b')
end
hold off
xlabel('Cavity Number')
ylabel('Beamwidth')