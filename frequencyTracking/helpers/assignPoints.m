function handles = assignPoints(handles)
    if isfield(handles,'tracks')
        if isfield(handles,'hPoly');
            handles = tracksView(handles);
            handles = addUndo(handles);
            
            selTrack = get(handles.tracksListBox,'Value');
            selTrack = selTrack(1);
            ids = unique([handles.tracks.id]);
            assignId = ids(selTrack);
            
            P = getPosition(handles.hPoly);
            selectedIdx = inpolygon([handles.tracks.t]',[handles.tracks.f1]',P(:,1),P(:,2));
           
            % Cannot have repeated times in the track being assigned to
            repeatIdx = [handles.tracks.id]==assignId & ~selectedIdx' & ismember([handles.tracks.t],[handles.tracks(selectedIdx).t]);
           
            % Cannot have repeated times in the selection
            selectedIdx = find(selectedIdx);
            [~,uniqueIdx,~] = unique([handles.tracks(selectedIdx).t]);
            selectedIdx = selectedIdx(uniqueIdx);
           
            [handles.tracks(selectedIdx).id] = deal(assignId);
            handles.tracks(repeatIdx) = [];
            
            handles = cleanTracks(handles);
            handles = populateTracksList(handles);
            handles = refreshPlot(handles);
        else
            handles = writeLog(handles,'No region selected');
        end
    else
        handles = writeLog(handles,'No tracks data');
    end
