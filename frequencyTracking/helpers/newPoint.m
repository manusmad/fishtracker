function handles = newPoint(handles)
    isConst = 1;
    if isfield(handles,'tracks')
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        selTrack = get(handles.tracksListBox,'Value');
        selTrack = selTrack(1);
        
        ids = unique([handles.tracks.id]);
        id = ids(selTrack);

        while isConst
            handles = writeLog(handles,'Select point to add to track %d',id);
            [time,freq] = MagnetGInput2(handles.hSpec,false);
            if ~isInRange(handles,time,freq)
                set(handles.constCheckBox,'Value',0);
                break;
            end

            if ~isempty(time) && ~isempty(freq)     
                handles = addPoints(handles,id,time,freq);
                handles = refreshPlot(handles);
            else
                handles = writeLog(handles,'No corresponding point found');
            end
            isConst = get(handles.constCheckBox,'Value');
        end
    else
        handles = writeLog(handles,'No tracks data');
    end