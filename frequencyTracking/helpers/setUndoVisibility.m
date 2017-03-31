function handles = setUndoVisibility(handles)
% SETUNDOVISIBILITY Changes visibility of undo and redo buttons based on
% whether undo and redo stacks are empty.
%
% Manu S. Madhav
% 2016

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