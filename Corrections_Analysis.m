%%
% Horizontal calibration of Hx
% Vertical calibration of Hy and beamwidth
clc
clear all
%Horizontal
%load('\\lpqm1srv3.epfl.ch\Nano\DAQsoftware\Image processing\20150710_C705_HalfHalf_SDSBridge_Pad_2mm\Horizontal\imData.mat')
load('\\lpqm1srv3.epfl.ch\Nano\DAQsoftware\Image processing\20150710_C705_HalfHalf_SDSBridge_Pad_2mm\Vertical\imData.mat')
%%
nSEM = length(imData);
%compute the central hole position
ch = zeros(nSEM,1);    
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
        %Centeral hole index;
        ch(iSEM) = chMod-sh;
    end
end
%% Designed Target Hole Sizes
 a=436; D=0.25; Hx0=165; Hy0=366; Ki=1.7592; Xsi=3.317;
 Eta=1.2;
 M=8;
 J=0:M;
 Design_Spacing = [328.3746,  334.9953,  349.2769,  369.9062,  393.0938,  413.7231 , 428.0047,  434.6254, 436, 436, 436, 436, 436,436,436, 436, 436, 436, 436,436,436,436,436,436,436];
 aVecT=ajeta(J/M,D,Eta);
 HxVec=hx_ellipse(aVecT,Hx0,Xsi,Ki)/2;
 HyVec=hy_ellipse(aVecT,Hy0,Xsi,Ki)/2;       
 for i=length(J):20
            HxVec(i)=Hx0/2;
            HyVec(i)=Hy0/2;
 end

%% To get the Final Ellipses Index list
nSEM=length(imData);
HoleMin=0;
HoleMax=0;
for i=1:nSEM
    nEllipses(i)=length(imData{i}.ellipses);
    for j=1:nEllipses(i)
        HoleIndex(j)=j-ch(i);
    end
    if HoleMin>min(HoleIndex)
        HoleMin=min(HoleIndex);
    end
    if HoleMax<max(HoleIndex)
        HoleMax=max(HoleIndex);
    end
    clear HoleIndex
end
EllipsesIndex=linspace(HoleMin,HoleMax,HoleMax-HoleMin+1);
%% Analysis of the results for all the images.
for i=1:nSEM
    clear HoleIndex;
    clear PitchIndex;
    clear PitchScaling;
    clear Radius_X;
    clear Radius_Y;
    clear Difference_X;
    clear Difference_Y;
    beamWidth(i)=imData{i}.beamWidth;
    imScale=imData{i}.imScale;
    nEllipses(i)=length(imData{i}.ellipses);
%     for j = 1:(nEllipses(i)-1)
%         Pitch(j) = imScale*hypot(imData{i}.ellipses{j+1}.X0_in-imData{i}.ellipses{j}.X0_in,imData{i}.ellipses{j+1}.Y0_in-imData{i}.ellipses{j}.Y0_in);
%     end
    for j=1:nEllipses(i)

        HoleIndex(j)=j-ch(i);
            % Here we calculate the scaling factor for each pitch. 
%             if j< nEllipses(i)
%              PitchScaling(j)=Pitch(j)/Design_Spacing(abs(HoleIndex(j))+1-1*(HoleIndex(j)<0));
%              end
        Radius_X(j)=imData{i}.ellipses{j}.a*imScale;
        Radius_Y(j)=imData{i}.ellipses{j}.b*imScale;

        Difference_X(j)=Radius_X(j)-HxVec(abs(HoleIndex(j))+1);
        Difference_Y(j)=Radius_Y(j)-HyVec(abs(HoleIndex(j))+1);
     end
%         % Fitting of the pitch scaling factor for each nanobeam
%         validPitch=1:(length(HoleIndex)-1);
%         PitchIndex=EllipsesIndex(validPitch); 
%         [xData, yData] = prepareCurveData( PitchIndex, PitchScaling );
%         % Set up fittype and options.
%          ft{i} = fittype( 'poly4' );
%         % Fit model to data.
%         [fitresult{i}, gof] = fit( xData, yData, ft{i} );
    
        for k=1:(HoleMax-HoleMin+1)
            if EllipsesIndex(k)>=min(HoleIndex) & EllipsesIndex(k)<max(HoleIndex)
                    
                EllipsesRadius_X(k,i)=Radius_X(find(HoleIndex==EllipsesIndex(k)));
                EllipsesRadius_Y(k,i)=Radius_Y(find(HoleIndex==EllipsesIndex(k)));
                EllipsesDifference_X(k,i)=Difference_X(find(HoleIndex==EllipsesIndex(k)));
                EllipsesDifference_Y(k,i)=Difference_Y(find(HoleIndex==EllipsesIndex(k)));
%                     if EllipsesIndex(k)<max(HoleIndex)
%                         EllipsesPitch(k,i)=Pitch(find(HoleIndex==EllipsesIndex(k)));
%                     else EllipsesPitch(k,i)=0;
%                     end
            else
            EllipsesRadius_X(k,i)=0;
            EllipsesRadius_Y(k,i)=0;
            EllipsesDifference_X(k,i)=0;
            EllipsesDifference_Y(k,i)=0;
%             EllipsesPitch(k,i)=0;
            end
        end
    Indexmin=min(HoleIndex);
    Indexmax=max(HoleIndex);

end
%%
for kk=1:(HoleMax-HoleMin+1)
%     if kk<(HoleMax-HoleMin+1)
%     EllipsePitchScaling(kk)=mean(EllipsesPitch(kk,(EllipsesPitch(kk,:)~=0)))/Design_Spacing(abs(EllipsesIndex(kk))+1-1*(EllipsesIndex(kk)<0));
%     end
    MeanEllipsesRadius_X(kk)=mean(EllipsesRadius_X(kk,(EllipsesRadius_X(kk,:)~=0)));
    MeanEllipsesRadius_Y(kk)=mean(EllipsesRadius_Y(kk,(EllipsesRadius_X(kk,:)~=0)));
    MeanEllipsesDifference_X(kk)=mean(EllipsesDifference_X(kk,(EllipsesRadius_X(kk,:)~=0)));
    MeanEllipsesDifference_Y(kk)=mean(EllipsesDifference_Y(kk,(EllipsesRadius_X(kk,:)~=0)));
end
% MeanScaling=mean(EllipsePitchScaling);
%% Plots of the fitting of Hx, Hy
        figure(1)

        hold on
        scatter(EllipsesIndex,MeanEllipsesDifference_X);
        scatter(EllipsesIndex,MeanEllipsesDifference_Y);

        hold off
        xlabel('Ellipses Index')
        ylabel('Difference between Measured and Design')


        
[xData, yData] = prepareCurveData( EllipsesIndex, MeanEllipsesDifference_Y );
% Set up fittype and options.
ft = fittype( 'a + b * exp(-(abs(x)/c)^d )', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Levenberg-Marquardt';
opts.Display = 'Off';
opts.StartPoint = [0.141886338627215 0.421761282626275 0.915735525189067 0.792207329559554];
% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure(1)
hold on
plot( fitresult, xData, yData );
hold off
%         figure(2)
%         hold on
%         scatter(EllipsesIndex,Difference_X);
%         scatter(HoleIndex,Difference_Y);
%         hold off
        xlabel('Ellipses Index')
        ylabel('Difference between Measured and Design')
        figure(1)
        hold on
        hold off
        legend('Hx','Hy','Pitch','Fitted Hy')

%% 
c1=3;
d1= 1.95;
c2=4.7;
d2=1.95;


a1=8;
b1= -7;

a2=1;
b2=4.5;


p(1,:)=[a1,b1,c1,d1];
p(2,:)=[a2,b2,c2,d2];

for i=1:length(EllipsesIndex)
FittedMeanHx(i)=p(1,1) + p(1,2) * exp(-(abs(EllipsesIndex(i))/p(1,3))^p(1,4) );
FittedMeanHy(i)=p(2,1) + p(2,2) * exp(-(abs(EllipsesIndex(i))/p(2,3))^p(2,4) );
end

figure(1)
hold on
scatter(EllipsesIndex,MeanEllipsesDifference_X);
plot(EllipsesIndex,FittedMeanHx);

hold off;
xlabel('Ellipses Index')
ylabel('Difference of Hx between measured and design')
legend('Hx','Fitted Hx')

figure(2)
hold on

scatter(EllipsesIndex,MeanEllipsesDifference_Y);
plot(EllipsesIndex,FittedMeanHy);
hold off;
xlabel('Ellipses Index')
ylabel('Difference of Hy between measured and design')
legend('Hy','Fitted Hy')
beamWidth_Mean=mean(beamWidth)
