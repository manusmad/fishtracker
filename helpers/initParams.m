function handles = initParams(handles)

    set(handles.prefixEdit,'String',handles.params.smrFilePrefix);
    set(handles.nFFTEdit,'String',num2str(handles.params.nFFT));
    set(handles.overlapEdit,'String',num2str(handles.params.overlap));
    set(handles.fResValTxt,'String',num2str(handles.params.fRes));
    set(handles.tResValTxt,'String',num2str(handles.params.tRes));
    set(handles.rangeF1Edit,'String',num2str(handles.params.rangeF1));
    set(handles.rangeF2Edit,'String',num2str(handles.params.rangeF2));
    set(handles.rangeT1Edit,'String',num2str(handles.params.rangeT1));
    set(handles.rangeT2Edit,'String',num2str(handles.params.rangeT2));
    
    if strcmp(handles.params.viewMode,'Threshold')
        set(handles.threshPanel,'Visible','on');
    else
        set(handles.threshPanel,'Visible','off');
    end
    set(handles.threshSlider,'Value',handles.params.thresh);
    set(handles.threshEdit,'String',num2str(handles.params.thresh));

    
    if strcmp(handles.params.viewChannel,'Single') || strcmp(handles.params.viewChannel,'Mean')
        set(handles.singlePlotPanel,'Visible','on');
        set(handles.multiPlotPanel,'Visible','off');
    else
        set(handles.singlePlotPanel,'Visible','off');
        set(handles.multiPlotPanel,'Visible','on');
    end
    
    set(handles.viewSpectrogramCheck,'Value',handles.params.viewSpec);
    set(handles.viewTracksCheck,'Value',handles.params.viewTracks);
    set(handles.trackHighlightCheck,'Value',handles.params.trackHighlight);
    
    idx = find(strcmp(get(handles.specPresetPopup,'String'),'Custom'),1);
    set(handles.specPresetPopup,'Value',idx);
    
    handles = computeResolutions(handles);
    handles = setUndoVisibility(handles);
    
    uistack(handles.multiPlotPanel,'top');
