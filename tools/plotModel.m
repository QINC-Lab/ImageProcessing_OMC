function plotModel(handles)

    en  = get(handles.modelCheckbox,'Enable');
    val = get(handles.modelCheckbox,'Value');
    
    %sh = 0;
    %sh = get(handles.slider1,'Value');
    [shArray,chArray] = findHolePosition(handles);
    imSel = get(handles.imSelPopUpMenu,'Value');
    sh = shArray(imSel);
    ch = chArray(imSel);
    resTest = get(handles.residualCheckbox,'Value');
    resLengthTest = get(handles.resLengthCheckbox,'Value');
    
    if val==1 && strcmp(en,'on')==1
        if resTest==0
            ax1 = handles.imPlot;
            hold(ax1,'on');
        else
            ax1 = handles.imSubPlot1;
            ax2 = handles.imSubPlot2;
            axis(ax1,'auto');
            if resLengthTest==0
                linkaxes([ax1 ax2],'x');
            else
                linkaxes([ax1 ax2],'off');
            end
            hold(ax1,'on');
            hold(ax2,'on');            
        end
        
        [Hx,Hy,d,~] = getModelValues();
        
        %axis(ax,'manual');
        
        delete(findobj(ax1.Children,'Tag','modelDistance'));
        delete(findobj(ax1.Children,'Tag','modelHx'));
        delete(findobj(ax1.Children,'Tag','modelHy'));
        
        
%         plD = plot(ax1,linspace(0.5+sh,-0.5+length(d)+sh,length(d)),d,'--g');
        plD = plot(ax1,linspace(1.5-ch,0.5+length(d)-ch,length(d)),d,'--g');
        plD.Tag = 'modelDistance';
%         plHx = plot(ax1,linspace(sh,length(Hx)+sh-1,length(Hx)),Hx,'--b');
        plHx = plot(ax1,linspace(1-ch,length(Hx)-ch,length(Hx)),Hx,'--b');
        plHx.Tag = 'modelHx';
%         plHy = plot(ax1,linspace(sh,length(Hy)+sh-1,length(Hy)),Hy,'--r');
        plHy = plot(ax1,linspace(1-ch,length(Hy)-ch,length(Hy)),Hy,'--r');
        plHy.Tag = 'modelHy';
        
        if resTest==1
            delete(findobj(ax2.Children,'Tag','diffDistance'));
            delete(findobj(ax2.Children,'Tag','diffHx'));
            delete(findobj(ax2.Children,'Tag','diffHy'));
            plt = ax1.Children;
            maxX = 0;
            minX = 0;
            for i = 1:length(plt)
                switch plt(i).Tag
                    case 'Holes - Holes Intervals'
                        x = plt(i).XData;
                        y = plt(i).YData;
                        if maxX<max(x(:))
                            maxX = max(x(:));
                        end
                        if minX>min(x(:))
                            minX = min(x(:));
                        end
                        %diffD = y' - d(linspace(1.5-sh,-0.5+length(d)-sh,length(d)));
                        diffD = y' - d(1+sh:sh+length(y));
                        if resLengthTest ==1 
                            plD_diff = plot(ax2,d(1+sh:sh+length(y)),diffD,'xg');
                        else
                            plD_diff = plot(ax2,x,diffD,'-g');
                        end
                        
                        plD_diff.Tag = 'diffDistance';
                    case 'Holes - Short Axis'
                        x = plt(i).XData;
                        y = plt(i).YData;
                        if maxX<max(x(:))
                            maxX = max(x(:));
                        end
                        if minX>min(x(:))
                            minX = min(x(:));
                        end
                        diffHy = y' - Hy(1+sh:sh+length(y));
                        if resLengthTest ==1 
                            plHy_diff = plot(ax2,Hy(1+sh:sh+length(y)),diffHy,'xr');
                            axis(ax2,'auto');
                        else
                            plHy_diff = plot(ax2,x,diffHy,'-r');
                        end
                        plHy_diff.Tag = 'diffHy';
                    case 'Holes - Long Axis'
                        x = plt(i).XData;
                        y = plt(i).YData;
                        if maxX<max(x(:))
                            maxX = max(x(:));
                        end
                        if minX>min(x(:))
                            minX = min(x(:));
                        end
                        diffHx = y' - Hx(1+sh:sh+length(y));
                        if resLengthTest ==1
                            plHx_diff = plot(ax2,Hx(1+sh:sh+length(y)),diffHx,'xb');
                            axis(ax2,'auto');
                        else
                            plHx_diff = plot(ax2,x,diffHx,'-b');
                        end
                        plHx_diff.Tag = 'diffHx';
                end
            end
        axis(ax1,'manual');
        axis(ax1,[minX-1 maxX+1 0 1]);
        axis(ax1,'auto y');
        end
    end