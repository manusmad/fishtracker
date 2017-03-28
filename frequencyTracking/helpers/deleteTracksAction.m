function handles = deleteTracksAction(handles)
% DELETETRACKSACTION GUI action to delete tracks
%
% Adds current state of tracks to the Undo stack, then calls deleteTracks
% with the currently selected track ids in the GUI. Then refreshes the tracks
% list.
%
% Manu S. Madhav
% 2016
% See also DELETETRACKS, POPULATETRACKSLIST

    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        if handles.params.trackHighlight
            selTracks = get(handles.tracksListBox,'Value');
            ids = unique([handles.tracks.id]);
            ids = ids(selTracks);
            handles = deleteTrack(handles,ids);
            handles = refreshPlot(handles);
            handles = writeLog(handles,'Tracks deleted');
        else
            handles = writeLog(handles,'Select track to delete (Right click to cancel)');
            [time,freq] = MagnetGInput2(handles.hTracks,true);
        
            if ~isempty(time)
                [handles,id] = matchTrack(handles,time,freq);
                handles = deleteTrack(handles,id);
                handles = refreshPlot(handles);
                handles = writeLog(handles,'Track %d deleted',id);
            else
                handles = writeLog(handles,'Delete cancelled');
            end
        end
    else
        handles = writeLog(handles,'No tracks to delete');
    end
