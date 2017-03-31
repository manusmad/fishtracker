function handles = selectTrackAction(handles)
% SELECTTRACKACTION GUI interface to select track by clicking in window.
%
% Prompts user to click on the plot, finds the nearest track to clicked
% point, and then select that track in the tracks listbox.
%
% Manu S. Madhav
% 2016
% See also MAGNETGINPUT2, MATCHTRACK, POPULATETRACKSLIST

    if isfield(handles,'tracks')
        handles = writeLog(handles,'Click to select track (Right click to cancel)');
        [time,freq] = MagnetGInput2(handles.hTracks,true);
        
        if ~isempty(time)
            handles = populateTracksList(handles);
            [handles,id] = matchTrack(handles,time,freq);
            ids = unique([handles.tracks.id]);
            val = find(ids==id,1);
            set(handles.tracksListBox,'Value',val);
            handles = refreshPlot(handles);
            handles = writeLog(handles,'Track %d selected',id);
        else
            handles = writeLog(handles,'Select cancelled');
        end
    else
        handles = writeLog(handles,'No tracks to select');
    end