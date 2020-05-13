function [imOut,HV] = imCrop(imIn,imSEMScale)
% Crop the background from the beam photonic craystal images without
% banners. It takes three image sections and find the beam by assuming that
% the relevant feature is brither than the background.
    
    
    
    % Crop the image CMi banner at the bottom
    %im = cropCMiBanner(imIn);
    
%     % Checking the orientation of the beam and rotating the image if needed
%     im = beamHorizontal(im);
%     
%     
% 
%     
%     % Crop the background in the height direction
%     im = imCropX(im); 
%     % Cropped possible remaining walls prependicular to the beam
%     im = imCropY(im);
%     % Re crop in x because the edges in the Y direction might have
%     % perturbed the cropping procedure in X the first time
%     im = imCropX(im); 
    
	[im,HV] = imCropXY(imIn,imSEMScale);
	
    % Cropping the beam until the images has no partial holes at the image
    % borders because it is a problem for the edge detection afterwards
    
    imOut = cropPartialHoles(im);
    
    % Show cropped image if need
    %figure;imshow(imOut);
    % Show original image if need
    %figure;imshow(imIn);
end