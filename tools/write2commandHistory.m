function write2commandHistory(handles,sAdd)

    sOld = get(handles.commandHistory,'String');
    sOld = cellstr(sOld);
    sNew = cell(length(cellstr(sOld))+1,1);
    sNew{1} = sAdd;
    sNew(2:end) = sOld(1:end);
    set(handles.commandHistory,'String',sNew);drawnow;

end