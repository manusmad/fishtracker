% Function to 'clean' tracks, i.e. delete tracks of length<2
function [handles,del] = cleanTracks(handles)
    ids = unique([handles.tracks.id]);
    del = 0;
    for id = ids
        track = handles.tracks([handles.tracks.id]==id);
        lTrack = length(track);
   
        if lTrack<=10
            handles = deleteTrack(handles,id);
            del = del+1;
        end
    end
    