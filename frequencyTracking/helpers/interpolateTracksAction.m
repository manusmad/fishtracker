function handles = interpolateTracksAction(handles)
% INTERPOLATETRACKSACTION GUI action to interpolate track points
%
% Adds current state of tracks to the Undo stack, then calls 
% interpolateTracks.
%
% Manu S. Madhav
% 2016
% See also INTERPOLATETRACKS

    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        handles = interpolateTracks(handles);
        
        handles = refreshPlot(handles);
        handles = writeLog(handles,'All tracks interpolated');
    else
        handles = writeLog(handles,'No tracks to interpolate');
    end
