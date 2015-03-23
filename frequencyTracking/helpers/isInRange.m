function out = isInRange(handles,time,freq)
    out = time>=handles.params.rangeT1 && time<= handles.params.rangeT2 && freq >= handles.params.rangeF1 && freq <= handles.params.rangeF2;      