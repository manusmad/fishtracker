function handles = clearTracks(handles) 
    if isfield(handles,'tracks')
        handles = rmfield(handles,'tracks');
        if isfield(handles,'tracksFileName')
            handles = rmfield(handles,'tracksFileName');
        end
        set(handles.tracksFileTxt,'String','<None>');
        handles.undo.empty();
        handles.redo.empty();
        handles = setUndoVisibility(handles);
        
        handles = writeLog(handles,'Cleared tracks data');
    else
        handles = writeLog(handles,'No tracks data to clear');
    end
