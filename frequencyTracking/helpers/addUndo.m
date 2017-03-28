function handles = addUndo(handles)
% ADDUNDO Adds current state of tracks to undo stack.
%
% Takes in the handles structure from the GUI, adds the current set of
% tracks to the undo stack, then sets the visibility of the Undo button.
%
% Manu S. Madhav
% 2016
% See also UNDO

    handles.undo.push(handles.tracks);
    handles.redo.empty();
    handles = setUndoVisibility(handles);