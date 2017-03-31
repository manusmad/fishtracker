function handles = viewModeChanged(handles)
% VIEWMODECHANGED GUI interface when channel view mode is changed.
%
% Selects and toggles visibility of the threshold or view choose panels based
% on the current channel view mode selected.
%
% Manu S. Madhav
% 2016

    if strcmp(handles.params.viewMode,'Threshold')
        set(handles.threshPanel,'Visible','on');
        set(handles.viewChoosePanel,'Visible','off');
    else
        set(handles.threshPanel,'Visible','off');
        set(handles.viewChoosePanel,'Visible','on');
    end