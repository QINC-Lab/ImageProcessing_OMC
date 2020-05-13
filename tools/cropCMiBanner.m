function imOut = cropCMiBanner(imIn)

    [Nx,~] = size(imIn);

    % The banner represents the 10% of the height
    nCut = round(0.89*Nx);
    imOut = imIn(1:nCut,:);

end