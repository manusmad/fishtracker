function handles = clearElec(handles)
% CLEARELEC Delete elec structure from memory
%
% Also checks for elec filename and metadata, and clears channel list
%
% Manu S. Madhav
% 2016
% See also POPULATECHANNELLIST

    if isfield(handles,'elec')
        handles = rmfield(handles,'elec');
        if isfield(handles,'elecFileName')
            handles = rmfield(handles,'elecFileName');
        end
        set(handles.elecFileTxt,'String','<None>');
        handles = writeLog(handles,'Cleared electrode data');
        
        if isfield(handles,'spec')
            handles.meta = handles.spec.meta;
        else
            handles = rmfield(handles,'meta');
        end
        
        handles = populateChannelList(handles);
    else
        handles = writeLog(handles,'No electrode data to clear');
    end

