function handles = joinTracksAction(handles)
% JOINTRACKSACTION GUI action to join two tracks
%
% Adds current state of tracks to the Undo stack. The user is then prompted 
% to click two points in the spectrogram window, which are then matched to 
% the nearest (time,freq) points. joinTracks is then called on these pairs 
% of coordinates.
% 
% Manu S. Madhav
% 2016
% See also JOINTRACKS, MATCHTRACK

    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        handles = writeLog(handles,'Select track 1 (Right click to cancel)');
        [time1,freq1] = MagnetGInput2(handles.hTracks,true);

        if ~isempty(time1)
            handles = writeLog(handles,'Select track 2 (Right click to cancel)');
            [time2,freq2] = MagnetGInput2(handles.hTracks,true);
            
            if ~isempty(time2)
                % Match tracks with fish
                [handles,id1] = matchTrack(handles,time1,freq1);
                [handles,id2] = matchTrack(handles,time2,freq2);
                [handles,~] = joinTracks(handles,id1,time1,id2,time2);

                handles = refreshPlot(handles);
                handles = writeLog(handles,'Tracks joined');
            else
                handles = writeLog(handles,'Join cancelled');
            end
        else
            handles = writeLog(handles,'Join cancelled');
        end
    else
        handles = writeLog(handles,'No tracks to join');
    end
