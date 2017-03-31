function handles = splitTracksAction(handles)
% SPLITTRACKSACTION GUI action to split track
%
% Adds current state of tracks to the Undo stack, then prompts the user to 
% select track to split. Finds the closest track to clicked point, and 
% calls splitTrack on that track.
%
% Manu S. Madhav
% 2016
% See also SPLITTRACK, MAGNETGINPUT2, MATCHTRACK

    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);

        handles = writeLog(handles,'Select track to split (Right click to cancel)');
        
        [time,freq] = MagnetGInput2(handles.hTracks,true);
        
        if ~isempty(time)
            [handles,id] = matchTrack(handles,time,freq);
            [handles,~] = splitTrack(handles,id,time);
            
            handles = refreshPlot(handles);
            handles = writeLog(handles,'Track %d split at time %.2f',id,time);
        else
            handles = writeLog(handles,'Split cancelled');
        end
    else
        handles = writeLog(handles,'No tracks to split');
    end