function handles = deleteChannels(handles)
% DELETECHANNELS Delete the channels selected in the GUI channel listbox.
% 
% Delete channels from both elec and spec structures.
%
% Manu S. Madhav
% 2016
% See also POPULATECHANNELLIST

    delidx = get(handles.channelListBox,'Value');
    
    handles.meta.chNum(delidx) = [];
    handles.meta.nCh = handles.meta.nCh - length(delidx);
    
    if isfield(handles,'elec')
        handles.elec.data(:,delidx) = [];
        handles.elec.meta = handles.meta;
    end
    
    if isfield(handles,'spec')
        handles.spec.S(:,:,delidx) = [];
        handles.Smag(:,:,delidx) = [];
        handles.normSmag(:,:,delidx) = [];
        handles.Sthresh(:,:,delidx) = [];
        handles.spec.meta = handles.meta;
    end
    
    set(handles.channelListBox,'Value',1);
    handles = createSubplots(handles);
    handles = populateChannelList(handles);
    handles = refreshPlot(handles);
    
    if ~isempty(delidx)
        handles = writeLog(handles,'Channel(s) deleted');
    end