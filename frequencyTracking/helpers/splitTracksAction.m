function handles = splitTracksAction(handles)
    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);

        handles = writeLog(handles,'Select track to split (Right click to cancel)');
        
        [time,freq] = MagnetGInput2(handles.hTracks,true);
        
        if ~isempty(time)
            [handles,id] = matchTrack(handles,time,freq);
            [handles,~] = splitTrack(handles,id,time);
            
            handles = refreshPlot(handles);
            handles = writeLog(handles,'Track %d split at time %.2f',id,time);
        else
            handles = writeLog(handles,'Split cancelled');
        end
    else
        handles = writeLog(handles,'No tracks to split');
    end