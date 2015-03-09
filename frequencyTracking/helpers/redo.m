% Main redo function
function handles = redo(handles)
    if isfield(handles,'tracks')
        if handles.redo.size()
            handles.undo.push(handles.tracks);
            handles.tracks = handles.redo.pop();           
            handles = setUndoVisibility(handles);
            handles = populateTracksList(handles);
            handles = refreshPlot(handles);
        else
            handles = writeLog(handles,'Nothing to redo');
        end
    else
        handles = writeLog(handles,'No tracks data found');
    end