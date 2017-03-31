function [handles,newId] = splitTrack(handles,id,time,newId)
% SPLITTRACK Function to split track.
%
% Splits track with identifier 'id' at 'time'. If 'newId' is not provided, 
% it is the biggest track id + 1. The latter track is assigned to newId.
%
% Manu S. Madhav
% 2016
% See also POPULATETRACKSLIST

    if nargin<4
        newId = max(unique([handles.tracks.id])) + 1;
    end
    
    idx = [handles.tracks.id]==id & [handles.tracks.t]>time;
    if any(idx)
        [handles.tracks(idx).id] = deal(newId);
    end   
    handles = populateTracksList(handles);
