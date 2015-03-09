function handles = viewModeChanged(handles)
    if strcmp(handles.params.viewMode,'Threshold')
        set(handles.threshPanel,'Visible','on');
        set(handles.viewChoosePanel,'Visible','off');
    else
        set(handles.threshPanel,'Visible','off');
        set(handles.viewChoosePanel,'Visible','on');
    end