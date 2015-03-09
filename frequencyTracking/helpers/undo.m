% Main undo function
function handles = undo(handles)
    if isfield(handles,'tracks')
        if handles.undo.size()
            handles.redo.push(handles.tracks);
            handles.tracks = handles.undo.pop();           
            handles = setUndoVisibility(handles);
            handles = populateTracksList(handles);
            handles = refreshPlot(handles);
        else
            handles = writeLog(handles,'Nothing to undo');
        end
    else
        handles = writeLog(handles,'No tracks data found');
    end