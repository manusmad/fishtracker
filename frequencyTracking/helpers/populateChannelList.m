% --- Function to populate the channel list box and clear the enable
% selections.
function handles = populateChannelList(handles)
    if isfield(handles,'meta')
        list = cell(handles.meta.nCh,1);
        for k = 1:handles.meta.nCh
            list{k} = sprintf('%s %02d',handles.meta.chPrefix,handles.meta.chNum(k));
        end
        set(handles.channelListBox,'String',list);
    else
        set(handles.channelListBox,'String','Channel list');
    end
    
