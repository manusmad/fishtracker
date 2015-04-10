% Function to find out which id the (time, freq) point belongs to
function [handles,matchid] = matchTrack(handles,time,freq)
    [~,idx] = min(pdist2([ [handles.tracks.t]' [handles.tracks.f1]' ],[time freq]));
    matchid = handles.tracks(idx).id;