function handles = overlapDn(handles)
    overlap = handles.params.overlap;
    overlap = 1/(1-overlap);
    npow2 = 2^nextpow2(overlap);
    
    if npow2 == overlap
        overlap = overlap/2;
    else
        overlap = npow2/2;
    end
    
    overlap = 1 - 1/overlap;
    handles.params.overlap = overlap;
    set(handles.overlapEdit,'String',num2str(overlap));