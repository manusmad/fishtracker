function subFigClickCallBack(hObject,~,handles)
% SUBFIGCLICKCALLBACK To change focus when a subfigure is clicked in 'All' view
%
% Manu S. Madhav
% 2016

    persistent chk
    if isempty(chk)
        chk = 1;
        pause(0.5); %Add a delay to distinguish single click from a double click
        if chk == 1
            % Single click
            % Find out which of the subfigures the click came through
            subIdx = find(ismember(handles.hSub,get(hObject,'Parent')));
            chan = get(handles.channelListBox,'Value');
            if chan ~= subIdx
                set(handles.channelListBox,'Value',subIdx);
                handles = refreshPlot(handles);
            end  
            chk = [];
        end
    else
        chk = [];
        % Double click
        subIdx = find(ismember(handles.hSub,get(hObject,'Parent')));
        set(handles.channelListBox,'Value',subIdx);
        handles.viewChannelsPanel.SelectedObject = handles.viewSingleRadioBtn;
        handles.params.viewChannel = 'Single';
        handles = viewChannelsChanged(handles);
    end