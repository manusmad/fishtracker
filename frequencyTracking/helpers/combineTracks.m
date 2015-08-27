% Function to combine multiple tracks
function handles = combineTracks(handles,ids)
    [handles.tracks(ismember([handles.tracks.id],ids)).id] = deal(ids(2));
    
    % Cannot have repeated times in the selection
    selectedIdx = find([handles.tracks.id]==ids(2));
    [~,uniqueIdx,~] = unique([handles.tracks(selectedIdx).t]);
    [handles.tracks(selectedIdx(uniqueIdx)).id] = deal(ids(1));