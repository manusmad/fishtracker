function ret = compareMetaAll(handles,except,meta)
% COMPAREMETAALL Checks whether both elec and spec are from the same data
% source
%
% Compares metadata structure meta to the existing spec and elec metadata
% structures. If either of these are to be ignored, pass except as either
% 'elec' or 'spec'. Returns 1 if metadata is the same, else 0.
%
% Manu S. Madhav
% 2016
% See also COMPAREMETA

    ret1 = 1;
    if isfield(handles,'elec') && ~strcmp(except,'elec')
        ret1 = compareMeta(handles.elec.meta,meta);
    end
    
    ret2 = 1;
    if isfield(handles,'spec') && ~strcmp(except,'spec')
        ret2 = compareMeta(handles.spec.meta,meta);
    end
    
    ret = ~any(~[ret1 ret2]);
    if ~ret
        handles = writeLog(handles,'Data is not from the same source');
    end