function handles = deletePoints(handles)
    if isfield(handles,'tracks')
        if isfield(handles,'hPoly');
            handles = tracksView(handles);
            handles = addUndo(handles);
            
            P = getPosition(handles.hPoly);
            selectedIdx = inpolygon([handles.tracks.t]',[handles.tracks.f1]',P(:,1),P(:,2));

            handles.tracks(selectedIdx) = [];
            
            handles = cleanTracks(handles);
            handles = populateTracksList(handles);
            handles = refreshPlot(handles);
        else
            handles = writeLog(handles,'No region selected');
        end
    else
        handles = writeLog(handles,'No tracks data');
    end