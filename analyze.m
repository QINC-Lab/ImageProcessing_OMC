%% load image and show the image
close all
clc
clear
%filename = 'D0308_12013.tif';
%foldername='C:\Users\lqiu\Documents\LPQM\SEM\20150310_D0308\155'
%filename =  'C:\Users\lqiu\Documents\LPQM\SEM\20150310_D0308\155\D0308_15521.tif';
%filename = 'C:\Users\lqiu\Documents\LPQM\SEM\20150413_C0408\C408_155_13.tif';
foldername =  '\\lpqm1srv3\Nano\DAQsoftware\Image processing\20150706_C705_HalfHalf_SDSBridge_Pad\2mm\PixelAve\';
figurename='C705_155_1D03';
tifname=[figurename,'.tif'];
filename=fullfile(foldername,tifname);
%filename =  'Y:\SEM pictures\PhotonicCrystals\lqiu20150413_C0408_2\20150402_Painter_WithoutCorrections.jpeg';

%RGB=imread(filename);
%im = rgb2gray(RGB)
im=imread(filename);
imshow(im);

%%
%Here are the real design parameters.
SweepFactor=1;
%Pitch,
Design_pitch   = [327, 329.74, 340.24, 358.3124, 381.500 , 404.68 , 422.758, 433.25, 436, 436, 436 ,436 ,436,436,436,436,436,436];
%Distance between hole centers.
Design_Spacing = [328.3746,  334.9953,  349.2769,  369.9062,  393.0938,  413.7231 , 428.0047,  434.6254, 436, 436, 436, 436, 436,436,436,436,436,436,436];
%Designed Parameters for Hx, Hy
Design_Hx    = SweepFactor*[99.50,99.10,97.50, 94.65, 90.93, 87.26, 84.48, 82.90, 82.5, 82.5, 82.5, 82.5, 82.5, 82.5,82.5,82.5, 82.5, 82.5];
Design_Hy    = SweepFactor*[85.00,87.04,95.01,109.51,129.52,151.16,169.16,180.08,183.0,183.0,183.0,183.0,183.0,183,183,183,183,183,183,183];
Design_width = SweepFactor*529;
%We do need to crop the image before we start.
prompt = {'Enter Rotation Degree:'};
dlg_title = 'Input Rotation Degree';
num_lines = 1;
def = {'0'};
Degree = inputdlg(prompt,dlg_title);  
RotationDegree=str2num(Degree{1});
I=imrotate(im,RotationDegree);
imshow(I);
I = imcrop(I);
imshow(I);

% Optimize image
J = imadjust(I);
J2=wiener2(J);
imshow(J2);

% Convert to binary image using automatic threshold
level = graythresh(J2);
BW = im2bw(J2,level);
imshow(BW);
% level = graythresh(I);
% BW = im2bw(I,level);
% imshow(BW);


%
%dim = size(BW)
%col = round(dim(2)/2)-90;
%row = min(find(BW(:,col)));
%boundary = bwtraceboundary(BW,[row, col],'N');
%imshow(J2)
%hold on;
%plot(boundary(:,2),boundary(:,1),'g','LineWidth',3);

% Detect all boundaries
BW_filled = imfill(BW,'holes');
boundaries = bwboundaries(BW,4);
clf;
imshow(J2);
hold on;
for k=1:length(boundaries)
   b = boundaries{k};
   plot(b(:,2),b(:,1),'g','LineWidth',1);
end
hold off;

i=1;
true=1;
NumBounds=size(boundaries);
while true
     NumPoints= size(boundaries{i});
     % This is a manual filtering step by removing the boundaries less than
     % 50 points
     if NumPoints(1)<50
     boundaries(i,:)=[];
     else i=i+1;
     end
     NumBounds=size(boundaries);
     if i>NumBounds(1)
         true=0;
     else end
end     
beam = boundaries{1};
holes = boundaries(2:end);

imshow(J2);
hold on;
for k=1:length(boundaries)
   b = boundaries{k};
   plot(b(:,2),b(:,1),'g','LineWidth',1);
end
hold off;



%% Analyze holes
for i=1:length(holes)
    Y = holes{i}(:,1);
    X = holes{i}(:,2);
    hold on;
    elip{i} = fit_ellipse(X,Y,gca);
    X0_in(i) = elip{i}.X0_in;
    Y0_in(i) = elip{i}.Y0_in;
    a0(i) = abs(elip{i}.a);
    b0(i) = abs(elip{i}.b);
    r0(i) = sqrt(a0(i)^2+b0(i)^2);
    d0(i) = sqrt(abs(a0(i)^2-b0(i)^2));
    hold off;
end
%Search for the central cavity. This needs to be optimized actually as
%sometimes the centeral cavity doesn't have smallest size.
[r0min,Ncenter]=min(r0);
% Plot results for Measured Pixcel Sizes for holes
figure;
xlabel('Hole Number');
ylabel('Measured Pixcel Sizes for Holes');
hold on;
i=1:length(holes);
plot(i-Ncenter,a0(i),'ob');
plot(i-Ncenter,b0(i),'or');
plot(i-Ncenter,r0, '-og');
hold off;
legend('Hx','Hy','Mean Radius');

%% Analyze edges
% Remove small vertical edges
horizEdges = beam(and(beam(:,2)>min(beam(:,2)),beam(:,2)<max(beam(:,2))),:);
% Divide the top and bottom egdes
topEdge = horizEdges(horizEdges(:,1)<mean(horizEdges(:,1)),:);
bottomEdge = horizEdges(horizEdges(:,1)>mean(horizEdges(:,1)),:);
% Fit line
pCenter = polyfit(X0_in,Y0_in,1);
pTop = polyfit(topEdge(:,2),topEdge(:,1),1);
pBottom = polyfit(bottomEdge(:,2),bottomEdge(:,1),1);

% Compute "ideal" edges lines
centerline      = polyval(pCenter,X0_in);
topIdealEdge = polyval(pTop,topEdge(:,2));
bottomIdealEdge = polyval(pBottom,bottomEdge(:,2));

figure
hold on
plot(X0_in,Y0_in,'.');
plot(X0_in,centerline);
plot(topEdge(:,2),topEdge(:,1),'.');
plot(topEdge(:,2),topIdealEdge);
plot(bottomEdge(:,2),bottomEdge(:,1),'.');
plot(bottomEdge(:,2),bottomIdealEdge);
hold off


% Compute residuals
%resTop = topEdge(:,1)-topIdealEdge;
%resBottom = bottomEdge(:,1)-bottomIdealEdge;

% Plot residuals
%figure('name','Beam horizontal edges residuals');
%plot(topEdge(:,2),resTop,'xb',bottomEdge(:,2),resBottom,'xr');
%legend('Top Edge','Bottom Edge');

%% Interpolation of the edge points

% Shifted duplication of the image
Ixm1 = double(J2(1:end-2,2:end-1));
Ixp1 = double(J2(3:end,2:end-1));
Iym1 = double(J2(2:end-1,1:end-2));
Iyp1 = double(J2(2:end-1,3:end));

% Computation of the directional gradients
Gx = 0.5*abs(Ixp1-Ixm1);
Gy = 0.5*abs(Iyp1-Iym1);

% figure;imagesc(J2);figure;imagesc(Gx);figure;imagesc(Gy);

% Gradient norm
% G = uint8(hypot(Gx,Gy));
% figure;imagesc(G);

% Detected edges
%  -  Remove small edges
horizEdges = beam(and(beam(:,2)>min(beam(:,2))+1,beam(:,2)<max(beam(:,2))-1),:); % + and -1 because of the cropping due to the gradient
%  -  Divide the top and bottom egdes
topEdge = horizEdges(horizEdges(:,1)<mean(horizEdges(:,1)),:);
bottomEdge = horizEdges(horizEdges(:,1)>mean(horizEdges(:,1)),:);
% hold on;
% plot(horizEdges(:,2)-1,horizEdges(:,1)-1,'.r');


% Interpolate the 'mass' center coordinate couples of the gradient map
[ny,nx] = size(J2);
[Xcoord,Ycoord] = meshgrid(2:nx-1,2:ny-1); % From 2 to end-1 because of the cropping due to the gradient

[Xinterp,Yinterp] = interpolateMassCenter(Xcoord,Ycoord,Gx,Gy);



topEdgeXinterp = diag(Xinterp(topEdge(:,1)-2,topEdge(:,2)-2)); % -2 factor due to the cropping from the gradient and the interpolation
topEdgeYinterp = diag(Yinterp(topEdge(:,1)-2,topEdge(:,2)-2));
bottomEdgeXinterp = diag(Xinterp(bottomEdge(:,1)-2,bottomEdge(:,2)-2));
bottomEdgeYinterp = diag(Yinterp(bottomEdge(:,1)-2,bottomEdge(:,2)-2));

% Fitting straight lines
pTop = polyfit(topEdgeXinterp,topEdgeYinterp,1);
pTopRaw = polyfit(topEdge(:,2),topEdge(:,1),1);
pBottom = polyfit(bottomEdgeXinterp,bottomEdgeYinterp,1);
pBottomRaw = polyfit(bottomEdge(:,2),bottomEdge(:,1),1);
% Compute "ideal" edges lines
topIdealEdge = polyval(pTop,topEdgeXinterp);
topIdealEdgeRaw = polyval(pTopRaw,topEdge(:,2));
bottomIdealEdge = polyval(pBottom,bottomEdgeXinterp);
bottomIdealEdgeRaw = polyval(pBottomRaw,bottomEdge(:,2));
% Compute residuals
resTop = topEdgeYinterp-topIdealEdge;
resTopRaw = topEdge(:,1)-topIdealEdgeRaw;
resBottom = bottomEdgeYinterp-bottomIdealEdge;
resBottomRaw = bottomEdge(:,1)-bottomIdealEdgeRaw;

% figure;imagesc(J2);colormap('gray');hold on;plot(topEdge(:,2),topEdge(:,1),'.b',topEdgeXinterp,topIdealEdge,'.r');

% Plot residuals
figure('name','Beam horizontal edges residuals');
subplot(211)
plot(topEdgeXinterp,resTop,'xb',topEdge(:,2),resTopRaw,'xr');
legend('Interpolated','Original','Location','SouthEast');title('Beam top edge');
subplot(212)
plot(bottomEdgeXinterp,resBottom,'xb',bottomEdge(:,2),resBottomRaw,'xr');
legend('Interpolated','Original','Location','SouthEast');title('Beam bottom edge');

figure;imshow(J2);
hold on;

% Same for the holes
for i=1:length(holes)
    holesY = holes{i}(:,1);
    holesX = holes{i}(:,2);
    
    holesXinterp = diag(Xinterp(holesY-2,holesX-2)); % -2 factor due to the cropping from the gradient and the interpolation
    holesYinterp = diag(Yinterp(holesY-2,holesX-2));
    
    %strPlotName=sprintf('Holes number %i',i);figure('name',strPlotName);plot(holesXinterp,holesYinterp,'b',holesX,holesY,'r');legend('Interpolated','Raw');
    
    elip{i} = fit_ellipse(holesXinterp,holesYinterp);
    fit_ellipse(holesXinterp,holesYinterp,gca,'g');
    fit_ellipse(holesX,holesY,gca,'r');
    
    deltaR2{i} = computeEllipseResiduals(elip{i},holesXinterp,holesYinterp); % deviation squared ! 
    
end

hold off;

%figure('name','Residual of holes number 7');plot((deltaR2{7}).^0.5);
%figure('name','Residual of holes number 5');plot((deltaR2{5}).^0.5);
%figure('name','Residual of holes number 11');plot((deltaR2{11}).^0.5);
%figure('name','Residual of holes number 12');plot((deltaR2{12}).^0.5);

%% Calibrations 

Nh = length(holes);
d = zeros(Nh-1,1);
for i = 1:Nh-1
    d(i) = hypot(elip{i+1}.X0_in-elip{i}.X0_in,elip{i+1}.Y0_in-elip{i}.Y0_in);
end
figure('name','Consecutive holes spacing distance');plot(d,'xb');xlabel('Hole Number');ylabel('Distance between successive holes [pix]');


%Distance between top edge and bottom edge
D=abs((pTop(2)-pBottom(2))*sqrt(1/(((pTop(1)+pBottom(1))/2)^2+1)));

% Finally, it is time for Calibration!
%Pitch,
Design_pitch   = [327, 329.74, 340.24, 358.3124, 381.500 , 404.68 , 422.758, 433.25, 436, 436, 436 ,436 ,436,436,436,436,];
%Distance between hole centers.
Design_Spacing = [328.3746,  334.9953,  349.2769,  369.9062,  393.0938,  413.7231 , 428.0047,  434.6254, 436, 436, 436, 436, 436,436,436,436,436,436,436];
HoleNum=linspace(-(Ncenter-1),(length(holes)-Ncenter),length(holes));
NumHoles=abs(HoleNum);

HoleDistance=0;
for i=1:length(holes)
    if NumHoles(i)~=0;
    HoleDistance=HoleDistance+Design_Spacing(NumHoles(i));
    else
    end
end
%To check whether the method for calibration by the pitch is fine.
for i=1:(length(holes)-1)
ScalingFactorPitch(i)=d(i)/Design_Spacing((abs(i-Ncenter+0.5))+0.5);
end
figure('name','Deviation of the Pitches')
plot(linspace(1,(length(holes)-1),length(holes)-1)-Ncenter,ScalingFactorPitch/mean(ScalingFactorPitch)-1,'o');
xlabel('Hole Number');
ylabel('Deviation of the Pitches');
savefig(fullfile(foldername,figurename));
%Calibration of the pixels to nm.
HoleDistance_Pixel=abs(max(X0_in)-min(X0_in))*sqrt(pCenter(1)^2+1);
ScalingFactor=HoleDistance/HoleDistance_Pixel

a0_Meas=a0*ScalingFactor;
b0_Meas=b0*ScalingFactor;
width_Meas=D*ScalingFactor;
%Design_Hx    = [99.50,99.10,97.50, 94.65, 90.93, 87.26, 84.48, 82.90, 82.5, 82.5, 82.5, 82.5, 82.5, 82.5, 82.5, 82.5];
%Design_Hy    = [85.00,87.04,95.01,109.51,129.52,151.16,169.16,180.08,183.0,183.0,183.0,183.0,183.0,183,183,183,183];
%Design_width = 529;

for i=1:length(HoleNum)
    HxDesigned(i)=Design_Hx(abs(i-Ncenter)+1);
    HyDesigned(i)=Design_Hy(abs(i-Ncenter)+1);
    a0Deviation(i)=(a0_Meas(i)-HxDesigned(i))/HxDesigned(i);
    b0Deviation(i)=(b0_Meas(i)-HyDesigned(i))/HyDesigned(i);
    b0Deviation(i)=(b0_Meas(i)-Design_Hy(abs(i-Ncenter)+1))/Design_Hy(abs(i-Ncenter)+1);
end

figure('name','Measured and Designed Sizes');
hold on;
plot(HoleNum,a0_Meas,'ob');
plot(HoleNum,b0_Meas,'or');
i=1:length(HoleNum);
%Re-changed to DesignX, which is the designed parameter from the central
%hole
DesignX = Design_Hx(abs(i-Ncenter)+1);
DesignY = Design_Hy(abs(i-Ncenter)+1);
plot(HoleNum,DesignX,'s-b');
plot(HoleNum,DesignY,'s-r');
hold off;
xlabel('Hole number');
ylabel('Measured hole size');
legend('Measured Hx','Measured Hy','Designed Hx','Designed Hy')


figure('name','Relative Error');
clf;
plot(HoleNum,a0Deviation,'b--o');
hold on
plot(HoleNum,b0Deviation,'r--o');
hold off
xlabel('Hole number');
ylabel('Relative Error');
legend('Minor axis','Major axis')


figure('name','Measured and Designed Difference');
a0Diff=a0_Meas-DesignX;
b0Diff=b0_Meas-DesignY;
hold on
plot(HoleNum,a0Diff,'--b');
plot(HoleNum,b0Diff,'--r');
legend('Difference Hx','Difference Hy')
hold off
xlabel('Hole number');
ylabel('Measured hole size Difference[nm]');

widthDiff=(width_Meas-Design_width)


Designed=[DesignX,DesignY];
Measured=[a0_Meas,b0_Meas];
Diff=[a0Diff,b0Diff];
Result=[Diff,Designed];
[DesignedSorted,Index] = sort(Designed);
MeasuredSorted=Measured(Index);
[DesignedSorted,Index] = sort(Designed);
DiffSorted=Diff(Index);

figure('name','Measured Holes Size vs Designed Holes Size');
hold on
plot(DesignX,a0_Meas,'bo')
plot(DesignY,b0_Meas,'ro')
hold off
xlabel='Designed Size';
ylabel='Measured Size';

%% Save Data
%filenameSPE = [filename,'.spe'];
%eval(['save ' widthDiff '.txt -ascii Result']);
a=436; D=0.25; Hx0=220; Hy0=400; Ki=1.7592; Xsi=3.317;
% Tapered section (J=0 is the central hole)
M=8;
Eta=1.19;
J=0:M;
aVecT=ajeta(J/M,D,Eta);
%Elipsoid SEMI axes
HxVec=hx(aVecT,Hx0,Xsi,Ki)/2;
HyVec=hy(aVecT,Hy0,Xsi,Ki)/2;

for i=1:length(HoleNum)
    if abs(HoleNum(i))<=8
        %Because of the central hole is HoleNum is 0.
    Hx(i)=HxVec(abs(HoleNum(i))+1);
    Hy(i)=HyVec(abs(HoleNum(i))+1);
    else 
    Hx(i)=HxVec(M+1);
    Hy(i)=HyVec(M+1);
    end
end
figure('name','Ebeam Pattern')
hold on
plot(HoleNum,a0_Meas-Hx,'sb');
plot(HoleNum,b0_Meas-Hy,'sr');
legend('Differ Hx','Differ Hy')
hold off
%% Residuls
%Centers coordinates
Xc = zeros(Nh,1);
Yc = zeros(Nh,1);
for i = 1:Nh
    Xc(i) = elip{i}.X0_in;
    Yc(i) = elip{i}.X0_in;
end

p = polyfit(Xc,Yc,1);

Yfit = polyval(p,Xc); 

% Residual 
Dy = Yfit-Yc;

figure('name','Alignement of the holes centers');plot(Dy);xlabel('Holes number');ylabel('Residual');
