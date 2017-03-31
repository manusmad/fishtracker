function handles = specCompute(handles)
% SPECCOMPUTE GUI interface to compute spectrogram
%
% Calls specFullFile on the electrode data using the current values of nFFT
% and overlap. Also computes the magnitude and normalized magnitude of the
% spectrogram, and sets GUI parameters.
%
% Manu S. Madhav
% 2016
% See also SPECFULLFILE, SETRANGES, COMPUTETHRESHOLD

    if isfield(handles,'elec')
        tic;
        spec = specFullFile(handles.elec,handles.params.nFFT,handles.params.overlap);
        spec.meta.nFFT = handles.params.nFFT;
        spec.meta.overlap = handles.params.overlap;
        handles.meta = spec.meta;
        handles.normSmag = normSpecMag(spec.S);
        handles.Smag = abs(spec.S);
        
        runTime = toc;
        handles.spec = spec;
        handles = setRanges(handles,spec.F(1),spec.F(end),spec.T(1),spec.T(end));
        handles = computeThreshold(handles);
        handles = refreshPlot(handles);
        set(handles.specFileTxt,'String',sprintf('Computed from electode data'));
        handles = writeLog(handles,'Spectrogram computed (%.2f s)',runTime);
    end
