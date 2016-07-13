function handles = interpolateTracksAction(handles)
    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        handles = interpolateTracks(handles);
        
        handles = refreshPlot(handles);
        handles = writeLog(handles,'All tracks interpolated');
    else
        handles = writeLog(handles,'No tracks to interpolate');
    end
