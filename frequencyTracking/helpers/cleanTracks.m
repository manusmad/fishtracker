function [handles,del] = cleanTracks(handles)
% CLEANTRACKS Delete tracks of length less than 10
%
% If any tracks are deleted, return value del is 1, else 0.
%
% Manu S. Madhav
% 2016
% See also CLEANTRACKSACTION,DELETETRACK

    ids = unique([handles.tracks.id]);
    del = 0;
    for id = ids
        track = handles.tracks([handles.tracks.id]==id);
        track = track(~isnan([track.f1]));
        lTrack = length(track);
   
        if lTrack<=10
            handles = deleteTrack(handles,id);
            del = del+1;
        end
    end
    