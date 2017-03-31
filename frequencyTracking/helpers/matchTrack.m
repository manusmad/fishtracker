function [handles,matchid] = matchTrack(handles,time,freq)
% MATCHTRACK Matches (time,freq) point to track
%
% Finds the closest track point to (time,freq) and returns the id of that
% track.
% 
% Manu S. Madhav
% 2016

    [~,idx] = min(pdist2([ [handles.tracks.t]' [handles.tracks.f1]' ],[time freq]));
    matchid = handles.tracks(idx).id;