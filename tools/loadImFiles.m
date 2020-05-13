function [imFiles,imPath] = loadImFiles(imPath,os)

    %%% FOR WINDOWS 
    if strcmp('win',os) == 1
        if strcmp(imPath(end),'\')~=1
            imPath = strcat(imPath,'\');
        end
    end

    %%% FOR MAC OS  
    if strcmp('unix',os) == 1      
        if strcmp(imPath(end),'/')~=1
           imPath = strcat(imPath,'/');
        end
    end
    imDir = strcat(imPath,'*.tif');
    imFiles = dir(imDir);
    imNames = {imFiles.name};
    test = strfind(imNames,'._');
    hiddenFiles = zeros(1,length(imNames));
    for i = 1:length(imNames)
        if isempty(test{i})==0
            hiddenFiles(i) = 1;
        end
    end
    imFiles=imFiles(hiddenFiles==0);

end