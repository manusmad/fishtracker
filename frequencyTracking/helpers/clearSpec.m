function handles = clearSpec(handles)
    if isfield(handles,'spec')
        handles = rmfield(handles,'spec');
        if isfield(handles,'specFileName')
            handles = rmfield(handles,'specFileName');
        end
        set(handles.specFileTxt,'String','<None>');
        handles = writeLog(handles,'Cleared spectrogram data');
         
        if isfield(handles,'elec')
            handles.meta = handles.elec.meta;
        else
            handles = rmfield(handles,'meta');
        end
        
        handles = populateChannelList(handles);
    else
        handles = writeLog(handles,'No spectrogram data to clear');
    end
    

