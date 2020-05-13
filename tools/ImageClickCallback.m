function [x,y] = ImageClickCallback ( objectHandle , eventData )
    axesHandle  = get(objectHandle,'Parent');
    coordinates = get(axesHandle,'CurrentPoint'); 
    coordinates = coordinates(1,1:2);
    x = coordinates(1);
    y = coordinates(2);
    disp(x,y);
end