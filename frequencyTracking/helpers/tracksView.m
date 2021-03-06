function handles = tracksView(handles)
% TRACKSVIEW Makes sure the view is optimal for tracks selection 
% and deletion (Single axis, normal view mode)
%
% Manu S. Madhav
% 2016

    if ~strcmp(handles.params.viewMode,'Normal')
        handles.viewModePanel.SelectedObject = handles.viewNormalRadioBtn;
        handles.params.viewMode = 'Normal';
        handles = viewModeChanged(handles);
    end
    if strcmp(handles.params.viewChannel,'All')
        handles.viewChannelsPanel.SelectedObject = handles.viewSingleRadioBtn;
        handles.params.viewChannel = 'Single';
        handles = viewChannelsChanged(handles);
    end
   