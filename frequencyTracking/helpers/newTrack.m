function handles = newTrack(handles)
    if isfield(handles,'spec')
            handles = tracksView(handles);
            newTrack = fillWithNaNs([],handles.spec.T,handles.spec.meta.chNum,handles.meta.chNumOrig);
            if isfield(handles,'tracks')
                handles = addUndo(handles);
                newId = max([handles.tracks.id])+1;
                [newTrack.id] = deal(newId);
                handles.tracks = [handles.tracks newTrack];
            else
                [newTrack.id] = deal(1);
                handles.tracks = newTrack;
            end
            
            handles = refreshPlot(handles);
            handles = populateTracksList(handles);
        else
            handles = writeLog(handles,'No spectrogram data available');
        end
