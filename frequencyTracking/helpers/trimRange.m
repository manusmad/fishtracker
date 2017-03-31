function handles = trimRange(handles)
% TRIMRANGE Trims frequency and time ranges of electrode and spectrogram
% data.
%
% Uses the entered values of range F1, F2, T1 and T2 to trim the
% spectrogram data. T1 and T2 are used to trim electrode data.
%
% Manu S. Madhav
% 2016
% See also COMPUTERESOLUTIONS, NORMSPECMAG

    if isfield(handles,'elec')
        elec = handles.elec;
        tidx = elec.t>=handles.params.rangeT1 & elec.t<=handles.params.rangeT2;
        elec.t = elec.t(tidx);
        elec.data = elec.data(tidx,:);
        elec.meta.N = length(elec.t);
        
        handles.elec = elec;
        handles.meta = elec.meta;
    end
    
    if isfield(handles,'spec')
        spec = handles.spec;
        tidx = spec.T>=handles.params.rangeT1 & spec.T<=handles.params.rangeT2;
        fidx = spec.F>=handles.params.rangeF1 & spec.F<=handles.params.rangeF2;
        
        spec.T = spec.T(tidx);
        spec.F = spec.F(fidx);
        spec.S = spec.S(fidx,tidx,:);
        spec.meta.N = (handles.params.rangeT2-handles.params.rangeT1)/spec.meta.int;
        
        handles.spec = spec;
        handles.meta = spec.meta;
        handles.normSmag = normSpecMag(spec.S);
        handles.Smag = abs(spec.S);
    end
    handles = computeResolutions(handles);