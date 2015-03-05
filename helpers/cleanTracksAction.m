function handles = cleanTracksAction(handles)
    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        [handles,del] = cleanTracks(handles);
        
        handles = refreshPlot(handles);
        handles = writeLog(handles,'%d tracks cleaned',del);
    else
        handles = writeLog(handles,'No tracks to clean');
    end
