function [imOut, HV]=imCropXY(imIn,imSEMScale)
 % Beamwidth set to be around 529nm,
 % Consider rotations within 45 degree to the horizontal or vertical plane.
 %This function detect the rotation of the nanobeam and rotate it to be 
 %horizontal and also crop the image to fit.
 % As for the images, the nanobeam is always brighter than the background
 % which is gray. Also, if there is a supporting pad in the figures,
 % special care need to be taken to crop the pad.
 
 BeamWidth=529;%nm
 %imSEMScale=getScaleSEM(imPath);
 %imSEMScale=getScaleSEM('\\lpqm1srv3.epfl.ch\Nano\DAQsoftware\Image processing\Images\E928_V\E928_155_1A11.tif')
 BeamPixel=BeamWidth/imSEMScale;
 imIn=cropCMiBanner(imIn);
 %[xlength, ylength]=size(imIn);
EdgeH=imIn(1,:);
EdgeV=imIn(:,1);
%=imIn(int64(length(xlength)),:);
%=imIn(int64(length(ylength)),:);
stdEdgeH=std(double(EdgeH));
stdEdgeV=std(double(EdgeV));
if stdEdgeH < stdEdgeV
	% Nanobeam is horizontal.
	HV=1;
	imOut=imIn;
else
	% Nanobeam is vertical.
	HV=0;
	imOut = uint8(rot90(imIn));
end
SmimOut=smooth(double(imOut(:,150)),20);
MeanimOut=nthroot(mean(SmimOut.^3),3);
BeamPart=SmimOut>MeanimOut;
BeamEdge=(BeamPart(1:end-1)-BeamPart(2:end));
[LeftEdge,LeftPos]=findpeaks(-BeamEdge);
[RightEdge,RightPos]=findpeaks(BeamEdge);

for indLeftEdge=1:length(LeftPos)
   for indRightEdge=1:length(RightPos)
		Dist=RightPos(indRightEdge)-LeftPos(indLeftEdge);
		if ((Dist>BeamPixel*0.5) && (Dist<BeamPixel*1.5))
			BeamEdges=[LeftPos(indLeftEdge),RightPos(indRightEdge)];
		end
   end
end
imOut=imOut((BeamEdges(1)-0.8*int64(BeamPixel)):((BeamEdges(2)+0.8*int64(BeamPixel))),:);
end