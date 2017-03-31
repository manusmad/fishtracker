function handles = viewChannelsChanged(handles)
% VIEWCHANNELSCHANGED GUI interface when channel view is changed.
%
% Selects and toggles visibility of the single or multi plot panels based
% on the current channel view selected.
%
% Manu S. Madhav
% 2016

    viewChannel = handles.params.viewChannel;
    if strcmp(viewChannel,'Single') || strcmp(viewChannel,'Mean')
        set(handles.singlePlotPanel,'Visible','on');
        set(handles.multiPlotPanel,'Visible','off');
    elseif strcmp(viewChannel,'All')
        set(handles.singlePlotPanel,'Visible','off');
        set(handles.multiPlotPanel,'Visible','on');
    end
    handles.params.viewChannel = viewChannel;