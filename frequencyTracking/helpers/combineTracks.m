function handles = combineTracks(handles,ids)
% COMBINETRACKS Combine multiple tracks into one track
%
% Finds all the unique times in all the tracks with identifiers in the
% vector ids, and chooses track points with the maximum amplitude at
% each unique time, and assigns all those points to the first id. The id of
% all other points are left unchanged.
%
% Manu S. Madhav
% 2016

    [handles.tracks(ismember([handles.tracks.id],ids)).id] = deal(ids(2));
    
    % Cannot have repeated times in the selection
    selectedIdx = find([handles.tracks.id]==ids(2));
    
    t = [handles.tracks(selectedIdx).t];
    a1 = [handles.tracks(selectedIdx).a1];
    uT = unique(t);
    
    for tu = uT
        tIdx = find(t==tu);
        [~,maxIdx] = max(sum(a1(:,tIdx)));
        handles.tracks(selectedIdx(tIdx(maxIdx))).id = ids(1);
    end