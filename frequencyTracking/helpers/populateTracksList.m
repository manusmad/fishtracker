function handles = populateTracksList(handles)
    if isfield(handles,'tracks')
        % If there are f1=NaN only arrays, eliminate them.
        ids = unique([handles.tracks.id]);
        for id = ids
            idx = [handles.tracks.id]==id;
            if ~any(~isnan([handles.tracks(idx).f1]))
                handles.tracks(idx) = [];
            end
        end
        
        ids = unique([handles.tracks.id]);
        handles.nTracks = length(ids);
        list = cell(handles.nTracks,1);
        col = distinguishable_colors(max(ids),{'r','k','y'});
        
        for k = 1:handles.nTracks
            coltag = reshape(dec2hex(round(col(ids(k),:)*255))',1,6);           
            list{k} = sprintf('<html><body bgcolor="%s">Track %02d</body></html>',coltag,ids(k));
        end
        set(handles.tracksListBox,'String',list);
        set(handles.tracksListBox,'ListboxTop',handles.nTracks);
        
        selTrack = get(handles.tracksListBox,'Value');
        if any(selTrack>handles.nTracks)
            set(handles.tracksListBox,'Value',handles.nTracks);
        end
        
        set(handles.nTracksTxt,'String',num2str(handles.nTracks));
    else
        set(handles.tracksListBox,'ListboxTop',1);
        set(handles.tracksListBox,'String','Tracks list');
        set(handles.nTracksTxt,'String','0');
    end

