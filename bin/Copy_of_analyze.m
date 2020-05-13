%% load image
filename = 'CavSweptFitted_AfterHF27.tif';
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

for i=1:length(holes)-1
    d(i) = sqrt(X0(i))
end
%% Plot results
plot(a0,'o');
