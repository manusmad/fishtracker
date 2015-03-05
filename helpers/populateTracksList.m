function handles = populateTracksList(handles)
    if isfield(handles,'tracks')
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
        if selTrack>handles.nTracks
            set(handles.tracksListBox,'Value',handles.nTracks);
        end
        
        set(handles.nTracksTxt,'String',num2str(handles.nTracks));
    else
        set(handles.tracksListBox,'String','Tracks list');
        set(handles.nTracksTxt,'String','0');
    end

