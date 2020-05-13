function imShowBoundaries(im,boundaries,imName)

    % Display image
    figure('name',strcat('Image ',imName,' with detected boundaries'));
    imshow(im);
    
    % Display boudaries
    hold on;
    for i = 1:length(boundaries)
        plot(boundaries{i}(:,2),boundaries{i}(:,1),'r');
    end
    hold off;

end