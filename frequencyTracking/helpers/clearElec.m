function handles = clearElec(handles)
    if isfield(handles,'elec')
        handles = rmfield(handles,'elec');
        if isfield(handles,'elecFileName')
            handles = rmfield(handles,'elecFileName');
        end
        set(handles.elecFileTxt,'String','<None>');
        handles = writeLog(handles,'Cleared electrode data');
        
        if isfield(handles,'spec')
            handles.meta = handles.spec.meta;
        else
            handles = rmfield(handles,'meta');
        end
        
        handles = populateChannelList(handles);
    else
        handles = writeLog(handles,'No electrode data to clear');
    end

