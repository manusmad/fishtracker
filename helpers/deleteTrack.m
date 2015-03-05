% Function to delete a track
function handles = deleteTrack(handles,ids)
    handles.tracks(ismember([handles.tracks.id],ids)) = [];
    handles = populateTracksList(handles);
    % If all tracks are deleted, 
    if handles.nTracks==0
        handles = rmfield(handles,'tracks');
    end
    
