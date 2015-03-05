function handles = initParams(handles)
    set(handles.log,'String',{''});
    set(handles.threshSlider,'Min',0.0);
    set(handles.threshSlider,'Max',1.0);
      
    % Undo and redo stacks
    handles.undo = CStack();
    handles.redo = CStack();
  
    % Parameter structure - All the global parameters which can be saved and
    % loaded should go here, and should be set in the function setParams
    handles.params.smrFilePrefix = 'Ch';
    handles.specPreset = 'Fine';
    handles.params.rangeF1 = 0;
    handles.params.rangeF2 = 100;
    handles.params.rangeT1 = 0;
    handles.params.rangeT2 = 1000;
    handles.params.viewMode = 'Normal';
    handles.params.viewChannel = 'Mean';
    handles.params.viewSpec = 1;
    handles.params.viewTracks = 1;
    handles.params.thresh = 0.2;
    handles.params.trackHighlight = 1;

    set(handles.prefixEdit,'String',handles.params.smrFilePrefix);
    set(handles.rangeF1Edit,'String',num2str(handles.params.rangeF1));
    set(handles.rangeF2Edit,'String',num2str(handles.params.rangeF2));
    set(handles.rangeT1Edit,'String',num2str(handles.params.rangeT1));
    set(handles.rangeT2Edit,'String',num2str(handles.params.rangeT2));
        
    set(handles.threshSlider,'Value',handles.params.thresh);
    set(handles.threshEdit,'String',num2str(handles.params.thresh));

    set(handles.viewSpectrogramCheck,'Value',handles.params.viewSpec);
    set(handles.viewTracksCheck,'Value',handles.params.viewTracks);
    set(handles.trackHighlightCheck,'Value',handles.params.trackHighlight);
    
    handles = setSpecPreset(handles);
    handles = computeResolutions(handles);
    handles = setUndoVisibility(handles);
    
    handles.
    handles = viewModeChanged(handles);
    
    handles = viewChannelsChanged(handles);

    
    uistack(handles.multiPlotPanel,'top');
