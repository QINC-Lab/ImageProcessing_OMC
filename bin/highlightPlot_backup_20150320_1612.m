function highlightPlot(handles,imDataMat)
    if nargin<2
        load(strcat(handles.imFullPath,'imData.mat'));
        imDataMat = cell2mat(imData);
    end

    % Color
    r = [1 0 0];
    b = [0 0 1];
    
    pltList = get(handles.plotShownListbox,'String');
    nPlt  = length(pltList);
    for i = 1:nPlt
        switch pltList{i}
            case 'Dose - Mean Roughness'
                dose = [imDataMat.imDose];
                %meanRough = [imDataMat.imMeanRough];
                ind = get(handles.imSelPopUpMenu,'Value');
                % Stupid lines to correct the index after the zeros are left aside
                aaa = zeros(length(dose),1);
                aaa(ind) = 1;
                aaa = aaa(dose~=0);
                sc = findobj(handles.imPlot.Children,'UserData','Dose - Mean Roughness');
                if dose(ind)~=0
                    
                    bin = dose(dose~=0);
                    ptsColor = zeros(length(bin),3);

                    for j = 1:length(bin)
                        if aaa(j)~=1
                            ptsColor(j,:) = b;
                        else
                            ptsColor(j,:) = r;
                        end
                    end
                else
                    bin = dose(dose~=0);
                    ptsColor = zeros(length(bin),3);
                    ptsColor(:,3) = 1;

                end
                set(sc,'CData',ptsColor);
     
            case 'Holes - Long Axis'
                
            case 'Holes - Short Axis'
               
            otherwise
                write2commandHistory(handles,'This plot type was added but is unknown of the highlightPlot() function. Please add this plot to the switch block in highlightPlot');
        end
    end
    


end