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
    handles = setSpecPreset(handles);

    handles.params.rangeF1 = 0;
    handles.params.rangeF2 = 100;
    handles.params.rangeT1 = 0;
    handles.params.rangeT2 = 1000;
    
    handles.params.minF1 = 200;
    handles.params.maxF1 = 800;
    handles.params.ratio12 = 8;
        
    handles.params.viewSpec = 1;
    handles.params.viewTracks = 1;
    handles.params.trackHighlight = 1;
   
    handles.params.thresh = 0.2;
   
    handles = setParams(handles);
    handles = setUndoVisibility(handles);
    
    handles.params.viewMode = 'Normal';
    handles.viewModePanel.SelectedObject = handles.viewNormalRadioBtn;
    handles = viewModeChanged(handles);
    
    handles.params.viewChannel = 'Mean';
    handles.viewChannelsPanel.SelectedObject = handles.viewMeanRadioBtn;
    handles = viewChannelsChanged(handles);

    uistack(handles.multiPlotPanel,'top');