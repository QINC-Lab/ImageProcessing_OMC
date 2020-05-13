%% load image
filename = 'CavSweptFitted_15501.tif';
%filename = 'ZEP_diffdose_HF0001.tif';
im=imread(filename);

%% Show and crop
imshow(im)
I = imcrop(im);

%% Optimize image
J = imadjust(I);
J2=wiener2(J);
imshow(J2);

%% Convert to binary image using automatic threshold
level = graythresh(J2);
BW = im2bw(J2,level);
imshow(BW);
% level = graythresh(I);
% BW = im2bw(I,level);
% imshow(BW);
%%
%dim = size(BW)
%col = round(dim(2)/2)-90;
%row = min(find(BW(:,col)));
%boundary = bwtraceboundary(BW,[row, col],'N');
%imshow(J2)
%hold on;
%plot(boundary(:,2),boundary(:,1),'g','LineWidth',3);
%% Detect all boundaries
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
beam = boundaries{1};
holes = boundaries(2:end);

%% Analyze holes
for i=1:length(holes)
    Y = holes{i}(:,1);
    X = holes{i}(:,2);
    hold on;
    elip{i} = fit_ellipse(X,Y,gca);
    X0(i) = elip{i}.X0;
    Y0(i) = elip{i}.Y0;
    a0(i) = abs(elip{i}.a);
    b0(i) = abs(elip{i}.b);
    
    hold off;
end
% 
% for i=1:length(holes)-1
%     d(i) = sqrt()
% end
%% Plot results
% plot(a0,'o');

%% Analyze edges
% Remove small vertical edges
horizEdges = beam(and(beam(:,2)>min(beam(:,2)),beam(:,2)<max(beam(:,2))),:);
% Divide the top and bottom egdes
topEdge = horizEdges(horizEdges(:,1)<mean(horizEdges(:,1)),:);
bottomEdge = horizEdges(horizEdges(:,1)>mean(horizEdges(:,1)),:);
% Fit line 
pTop = polyfit(topEdge(:,2),topEdge(:,1),1);
pBottom = polyfit(bottomEdge(:,2),bottomEdge(:,1),1);

% Compute "ideal" edges lines
topIdealEdge = polyval(pTop,topEdge(:,2));
bottomIdealEdge = polyval(pBottom,bottomEdge(:,2));

% Compute residuals
resTop = topEdge(:,1)-topIdealEdge;
resBottom = bottomEdge(:,1)-bottomIdealEdge;

% Plot residuals
figure('name','Beam horizontal edges residuals');
plot(topEdge(:,2),resTop,'xb',bottomEdge(:,2),resBottom,'xr');
legend('Top Edge','Bottom Edge');


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

figure('name','Residual of holes number 7');plot((deltaR2{7}).^0.5);
figure('name','Residual of holes number 5');plot((deltaR2{5}).^0.5);
figure('name','Residual of holes number 11');plot((deltaR2{11}).^0.5);
figure('name','Residual of holes number 12');plot((deltaR2{12}).^0.5);

%% Checking the spacing between the hole centers and their alignement
Nh = length(holes);
d = zeros(Nh-1,1);
for i = 1:Nh-1
    d(i) = hypot(elip{i+1}.X0_in-elip{i}.X0_in,elip{i+1}.Y0_in-elip{i}.Y0_in);
end

figure('name','Consecutive holes spacing distance');plot(d,'xb');xlabel('-');ylabel('Distance between successive holes [pix]');

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
