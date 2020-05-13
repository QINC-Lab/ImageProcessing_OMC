function [Hx,Hy,d,bW] = getModelValues()

    % Length in [nm]
    
    bW = 529; % Beam width
    
    nhd = 436*ones(8,1); %nominal holes distance
    chd = 328.3746; % center hole distance
    thd =[334.9953;349.2769;369.9062;393.0938;413.7231;428.0047;434.6254]; % tapered holes distance
    d = cat(1,nhd,nhd,flipud(thd),chd,chd,thd,nhd,nhd);

    nhHx = 2*82.5*ones(8,1); %nominal holes Hx
    chHx = 2*99.5;
    thHx = 2*[99.1;97.5;94.65;90.93;87.26;84.48;82.9;82.5];
    Hx = cat(1,nhHx,nhHx,flipud(thHx),chHx,thHx,nhHx,nhHx);
    
    nhHy = 2*183*ones(8,1); %nominal holes Hy
    chHy = 2*85;
    thHy = 2*[87.04;95.01;109.51;129.52;151.16;169.16;180.08;183];
    Hy = cat(1,nhHy,nhHy,flipud(thHy),chHy,thHy,nhHy,nhHy);

end