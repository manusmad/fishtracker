function handles = cleanTracksAction(handles)
% CLEANTRACKSACTION GUI action to clean tracks
%
% Adds current state of tracks to the Undo stack, then cleans tracks and
% refreshes plot.
%
% Manu S. Madhav
% 2016
% See also CLEANTRACKS

    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        [handles,del] = cleanTracks(handles);
        
        handles = refreshPlot(handles);
        handles = writeLog(handles,'%d tracks cleaned',del);
    else
        handles = writeLog(handles,'No tracks to clean');
    end
