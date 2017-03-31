function handles = newLine(handles)
% NEWLINE GUI interface for adding a new line to a track. 
%
% Prompts the user to click two points, and calls the addLine function 
% with the currently selected track id and the two points.
%
% Manu S. Madhav
% 2016
% See also ADDLINE

    isConst = 1;
       
    if isfield(handles,'tracks')
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        selTrack = get(handles.tracksListBox,'Value');
        selTrack = selTrack(1);
        
        ids = unique([handles.tracks.id]);
        id = ids(selTrack);
        
        while isConst
            handles = writeLog(handles,'Select end points of line to add to track %d',id);
            [time1,freq1] = MagnetGInput2(handles.hSpec,false);
            if ~isInRange(handles,time1,freq1)
                set(handles.constCheckBox,'Value',0);
                break;
            end
            [time2,freq2] = MagnetGInput2(handles.hSpec,false);
            if ~isInRange(handles,time2,freq2)
                set(handles.constCheckBox,'Value',0);
                break;
            end

            if ~isempty(time1) && ~isempty(freq1) && ~isempty(time2) && ~isempty(freq2)    
                handles = addLine(handles,id,time1,freq1,time2,freq2);
                handles = refreshPlot(handles);              
                isConst = get(handles.constCheckBox,'Value');
            else
                handles = writeLog(handles,'No corresponding point found');
            end
        end
    else
        % Need to make a new track
        handles = writeLog(handles,'No tracks data');
    end