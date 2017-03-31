function handles = redo(handles)
% REDO Main redo function
%
% Push the current tracks state to the undo stack. Pop the first element 
% from the redo stack, and make that the current tracks state.
%
% Manu S. Madhav
% 2016
% See also SETUNDOVISIBILITY, POPULATETRACKSLIST

    if isfield(handles,'tracks')
        if handles.redo.size()
            handles.undo.push(handles.tracks);
            handles.tracks = handles.redo.pop();           
            handles = setUndoVisibility(handles);
            handles = populateTracksList(handles);
            handles = refreshPlot(handles);
        else
            handles = writeLog(handles,'Nothing to redo');
        end
    else
        handles = writeLog(handles,'No tracks data found');
    end