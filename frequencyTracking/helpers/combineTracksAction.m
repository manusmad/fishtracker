function handles = combineTracksAction(handles)
    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);

        if handles.params.trackHighlight
            selTracks = get(handles.tracksListBox,'Value');
            if length(selTracks)>=2
                ids = unique([handles.tracks.id]);
                ids = ids(selTracks);
                handles = combineTracks(handles,ids);
                set(handles.tracksListBox,'Value',selTracks(1));
                handles = populateTracksList(handles);
                handles = refreshPlot(handles);
                handles = writeLog(handles,'Tracks %s combined',num2str(ids));
            else
                handles = writeLog(handles,'Select two or more tracks to combine');
            end
        else
            handles = writeLog(handles,'Highlight two or more tracks to combine');
        end
    else
        handles = writeLog(handles,'No tracks to combine');
    end