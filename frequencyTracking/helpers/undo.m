function handles = undo(handles)
% UNDO Main undo function
%
% Push the current tracks state to the redo stack. Pop the first element 
% from the undo stack, and make that the current tracks state.
%
% Manu S. Madhav
% 2016
% See also SETUNDOVISIBILITY, POPULATETRACKSLIST

    if isfield(handles,'tracks')
        if handles.undo.size()
            handles.redo.push(handles.tracks);
            handles.tracks = handles.undo.pop();           
            handles = setUndoVisibility(handles);
            handles = populateTracksList(handles);
            handles = refreshPlot(handles);
        else
            handles = writeLog(handles,'Nothing to undo');
        end
    else
        handles = writeLog(handles,'No tracks data found');
    end