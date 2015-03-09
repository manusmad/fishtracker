% Function to split track of fish given id and time to split
function [handles,newId] = splitTrack(handles,id,time,newId)
    if nargin<4
        newId = max(unique([handles.tracks.id])) + 1;
    end
    
    idx = [handles.tracks.id]==id & [handles.tracks.t]>time;
    if any(idx)
        [handles.tracks(idx).id] = deal(newId);
    end   
    handles = populateTracksList(handles);
