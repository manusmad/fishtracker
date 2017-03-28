function handles = clearTracks(handles)
% CLEARELEC Delete tracks structure from memory
%
% Also checks for tracks filename, and clears tracks list
%
% Manu S. Madhav
% 2016
% See also POPULATETRACKSLIST

    if isfield(handles,'tracks')
        handles = rmfield(handles,'tracks');
        if isfield(handles,'tracksFileName')
            handles = rmfield(handles,'tracksFileName');
        end
        set(handles.tracksListBox,'Value',1);
        set(handles.tracksFileTxt,'String','<None>');
        handles.undo.empty();
        handles.redo.empty();
        handles = setUndoVisibility(handles);
        handles = populateTracksList(handles);

        handles = writeLog(handles,'Cleared tracks data');
    else
        handles = writeLog(handles,'No tracks data to clear');
    end
