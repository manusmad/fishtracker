function [handles,id1] = joinTracks(handles,id1,time1,id2,time2)
% JOINTRACKS Function to join two tracks
%
% Splits track id1 at time t1 and track id2 at time t2. Then joins tracs 
% from time1 to time 2 and assigns it to id1, and returns id1.
%
% Manu S. Madhav
% 2016
% See also SPLITTRACK

    if time1>time2
        % Swap
        temp = id2; id2 = id1; id1 = temp;
        temp = time2; time2 = time1; time1 = temp;
    end

    idx1 = find([handles.tracks.id]==id1 & [handles.tracks.t]==time1,1);
    idx2 = find([handles.tracks.id]==id2 & [handles.tracks.t]==time2,1);
    
    if id1 == id2
        [handles,id12] = splitTrack(handles,id1,time1);
        [handles,~] = splitTrack(handles,id12,time2,id1);
    else
        % Split both tracks at the clicked points
        [handles,~] = splitTrack(handles,id1,time1);
        [handles,~] = splitTrack(handles,id2,time2,id1);
    end
    
    handles.tracks(idx1).id = id1;
    handles.tracks(idx2).id = id1;
    handles = populateTracksList(handles);
