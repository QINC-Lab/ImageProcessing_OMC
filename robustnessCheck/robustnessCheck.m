function robustnessCheck()

    % Add the tool functions to the path
    addpath '../tools/';
    
    % Initialization 
    n = 100;
    bw = zeros(1,n); % beam width
    hx = cell(1,n); % Holes Hx
    hy = cell(1,n); % Holes Hy
    snr_in = 0.01; % SNR
    
    imName = '../new/cropIm/C408_15518.tif';
    % Retrieving image scale
    load('../new/imData.mat');
    imDataM = cell2mat(imData);
    indIm = find(strncmp(imName(end-13:end),{imDataM.imName},300)==1);
    scl = imData{indIm}.imScale;
    % Loading the image
    im = imread(imName);
    
    % Loop for the different realizations
    for i = 1:n
        % Adding gaussian noise
        im_n = uint8(round(double(im) + snr_in*(double(max(im(:))-min(im(:))))*randn(size(im))));
        
        % Thresholding the image 
        imBW = imThresholding(im_n);

        % Detecting boundaries
        boundaries = bwboundaries(imBW,4);

        % Clean boudaries from noise 
        boundaries = clearNoiseBoundaries(boundaries);

        % Interpolation of the edges 
        [intX,intY] = interpolEdges(im);

        % Seperate the beam from the holes 
        beam = boundaries{1};
        holes = boundaries(2:end);

        % Fit the ellipses on the holes using the interpolated edges
        [fittedHoles,~] = fitHoles(holes,intX,intY);

        % Crop the bended part of the beam if needed
        beam = cropBendedPart(beam,fittedHoles);

        % Fit line to the beam edges
        [edgeTop,~,~,~,pTop,pBottom] = fitBeamEdges(beam,fittedHoles,intX,intY);


        % Computing the fitted data
        edgeTopFit = edgeTop;
        edgeTopFit(:,1) = polyval(pTop,edgeTop(:,2));
        edgeTopFit(:,2) = edgeTop(:,2);
        % edgeBottomFit = edgeBottom;
        % edgeBottomFit(:,1) = polyval(pBottom,edgeBottom(:,2));
        % edgeBottomFit(:,2) = edgeBottom(:,2);

        % Computing the beam width
        x1 = edgeTopFit(40,2);
        y1 = edgeTopFit(40,1);
        x2 = edgeTopFit(end-40,2);
        y2 = edgeTopFit(end-40,1);
        dx = abs(x2-x1);
        dy = abs(y2-y1);                    
        x3 = x1-dy;
        y3 = y1+dx;
        dx = abs(x1-x3);
        dy = abs(y1-y3);
        a  = atan(dx/dy);
        beamWidth = cos(a)*(abs(polyval(pTop,40) - polyval(pBottom,40) ))*scl;

        bw(i) = beamWidth;
        fittedHoles = cell2mat(fittedHoles);
        hx{i} = 2*scl*[fittedHoles.b];
        hy{i} = 2*scl*[fittedHoles.a];

    end
    
    f1 = figure('name','Beam width');
    f2 = figure('name','Hx');
    f3 = figure('name','Hy');
    plot(f1,bw,'xb');
    hold(axes(f2),'on');
    hold(axes(f3),'on');
    for i=1:100
        plot(f2,hx{i},'xb');
        plot(f3,hy{i},'xb');
    end

end