% Main Keypress handling function, add keyboard shortcuts here 
function handles = manageKeyPresses(handles,eventdata)
    if strcmp(eventdata.Key,'z') && ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier,'control')
        handles = undo(handles);
    elseif strcmp(eventdata.Key,'u') && isempty(eventdata.Modifier)
        handles = undo(handles);
    elseif strcmp(eventdata.Key,'y') && ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier,'control')
        handles = redo(handles);
    elseif strcmp(eventdata.Key,'r') && isempty(eventdata.Modifier)
        handles = redo(handles);
    elseif strcmp(eventdata.Key,'j') && isempty(eventdata.Modifier)
        handles = joinTracksAction(handles);
    elseif strcmp(eventdata.Key,'s') && isempty(eventdata.Modifier)
        handles = splitTracksAction(handles);
    elseif any(strcmp(eventdata.Key,{'d','delete'})) && isempty(eventdata.Modifier)
        handles = deleteTracksAction(handles);
    elseif strcmp(eventdata.Key,'c') && isempty(eventdata.Modifier)
        handles = cleanTracksAction(handles);
    elseif strcmp(eventdata.Key,'x') && isempty(eventdata.Modifier)
        handles = selectTrackAction(handles);
    end