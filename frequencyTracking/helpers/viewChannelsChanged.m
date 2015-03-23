function handles = viewChannelsChanged(handles)
    viewChannel = handles.params.viewChannel;
    if strcmp(viewChannel,'Single') || strcmp(viewChannel,'Mean')
        set(handles.singlePlotPanel,'Visible','on');
        set(handles.multiPlotPanel,'Visible','off');
    elseif strcmp(viewChannel,'All')
        set(handles.singlePlotPanel,'Visible','off');
        set(handles.multiPlotPanel,'Visible','on');
    end
    handles.params.viewChannel = viewChannel;