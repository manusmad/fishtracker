function handles = addUndo(handles)
    handles.undo.push(handles.tracks);
    handles.redo.empty();
    handles = setUndoVisibility(handles);