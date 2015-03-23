function ret = compareMetaAll(handles,except,meta)
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