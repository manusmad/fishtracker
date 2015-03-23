function handles = setUndoVisibility(handles)
    if handles.undo.size()
        set(handles.tracksUndoBtn,'Enable','on');
    else
        set(handles.tracksUndoBtn,'Enable','off');
    end
    
    if handles.redo.size()
        set(handles.tracksRedoBtn,'Enable','on');
    else
        set(handles.tracksRedoBtn,'Enable','off');
    end