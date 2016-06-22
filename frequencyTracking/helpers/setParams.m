function handles = setParams(handles)

set(handles.prefixEdit,'String',handles.params.smrFilePrefix);
    
set(handles.nFFTEdit,'String',num2str(handles.params.nFFT));
set(handles.overlapEdit,'String',num2str(handles.params.overlap));

set(handles.rangeF1Edit,'String',num2str(handles.params.rangeF1));
set(handles.rangeF2Edit,'String',num2str(handles.params.rangeF2));
set(handles.rangeT1Edit,'String',num2str(handles.params.rangeT1));
set(handles.rangeT2Edit,'String',num2str(handles.params.rangeT2));

set(handles.minF1Edit,'String',num2str(handles.params.minF1));
set(handles.maxF1Edit,'String',num2str(handles.params.maxF1));
set(handles.ratio12Edit,'String',num2str(handles.params.ratio12));

set(handles.viewSpectrogramCheck,'Value',handles.params.viewSpec);
set(handles.viewTracksCheck,'Value',handles.params.viewTracks);
set(handles.trackHighlightCheck,'Value',handles.params.trackHighlight);

set(handles.threshSlider,'Value',handles.params.thresh);
set(handles.threshEdit,'String',num2str(handles.params.thresh));

handles = computeResolutions(handles);
handles = computeThreshold(handles);
handles = refreshPlot(handles);