function handles = populateChannelList(handles)
% POPULATECHANNELLIST Function to populate the channel listbox.
%
% Fills the channel listbox with information from the metadata structure.
% 
% Manu S. Madhav
% 2016

    if isfield(handles,'meta')
        list = cell(handles.meta.nCh,1);
        for k = 1:handles.meta.nCh
            list{k} = sprintf('%s %02d',handles.meta.chPrefix,handles.meta.chNum(k));
        end
        set(handles.channelListBox,'String',list);
    else
        set(handles.channelListBox,'String','Channel list');
    end
    
