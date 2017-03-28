function handles = deleteTrack(handles,ids)
% DELETETRACK Deletes tracks
%
% Deletes all the tracks with identifiers in the vector ids.
%
% Manu S. Madhav
% 2016
    handles.tracks(ismember([handles.tracks.id],ids)) = [];
    handles = populateTracksList(handles);
    % If all tracks are deleted, 
    if handles.nTracks==0
        handles = rmfield(handles,'tracks');
    end
    
