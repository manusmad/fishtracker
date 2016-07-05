% Function to combine multiple tracks
function handles = combineTracks(handles,ids)
    [handles.tracks(ismember([handles.tracks.id],ids)).id] = deal(ids(2));
    
    % Cannot have repeated times in the selection
    selectedIdx = find([handles.tracks.id]==ids(2));
%     [uniqueT,uniqueIdx,~] = unique([handles.tracks(selectedIdx).t]);
    
    t = [handles.tracks(selectedIdx).t];
    a1 = [handles.tracks(selectedIdx).a1];
    uT = unique(t);
    
%     uIdx = zeros(size(uT));
    for tu = uT
        tIdx = find(t==tu);
        [~,maxIdx] = max(sum(a1(:,tIdx)));
        handles.tracks(selectedIdx(tIdx(maxIdx))).id = ids(1);
    end
    
    
%     [handles.tracks(selectedIdx(uniqueIdx)).id] = deal(ids(1));