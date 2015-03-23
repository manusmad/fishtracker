function handles = setSpecPreset(handles)
    preset = handles.specPreset;
    if strcmp(preset,'Rough')
        handles.params.nFFT = 16384;
        handles.params.overlap = 0.5;
    elseif strcmp(preset,'Fine')
        handles.params.nFFT = 32768;
        handles.params.overlap = 0.875;
    elseif strcmp(preset,'Tank')
        handles.params.nFFT = 16384;
        handles.params.overlap = 0.9375;
    end
    set(handles.nFFTEdit,'String',num2str(handles.params.nFFT));
    set(handles.overlapEdit,'String',num2str(handles.params.overlap));