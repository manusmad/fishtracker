function handles = specCompute(handles)
    if isfield(handles,'elec')
        tic;
        spec = specFullFile(handles.elec,handles.params.nFFT,handles.params.overlap);
        spec.meta.nFFT = handles.params.nFFT;
        spec.meta.overlap = handles.params.overlap;
        handles.meta = spec.meta;
        handles.Smag = normSpecMag(spec.S);

        runTime = toc;
        handles.spec = spec;
        handles = setRanges(handles,spec.F(1),spec.F(end),spec.T(1),spec.T(end));
        handles = computeThreshold(handles);
        handles = refreshPlot(handles);
        set(handles.specFileTxt,'String',sprintf('Computed from electode data'));
        handles = writeLog(handles,'Spectrogram computed (%.2f s)',runTime);
    end
