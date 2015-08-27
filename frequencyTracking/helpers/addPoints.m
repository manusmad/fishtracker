function handles = addPoints(handles,id,time,freq)
    [~,tidx] = ismember(time,handles.spec.T);
    [~,f1idx] = ismember(freq,handles.spec.F);
    [~,f2idx] = ismember(freq*2,handles.spec.F);
    [~,f3idx] = ismember(freq*3,handles.spec.F);
    
    NanV = nan(size(handles.spec.S,3),1);
    
    for k = 1:length(tidx)
        % Cannot have two points at the same time with the same id
        repeatIdx = [handles.tracks.t]==time(k) & [handles.tracks.id]==id;
        handles.tracks(repeatIdx) = [];
                
        [newTrackPt.t,newTrackPt.f1,newTrackPt.a1,newTrackPt.a2,newTrackPt.a3,...
        newTrackPt.p1,newTrackPt.p2,newTrackPt.p3,newTrackPt.id] = deal(NaN);
        
        newTrackPt.t = time(k);
        newTrackPt.f1 = freq(k);
        
        if f1idx(k)
            newTrackPt.a1 = squeeze(abs(handles.spec.S(f1idx(k),tidx(k),:)));
            newTrackPt.p1 = squeeze(angle(handles.spec.S(f1idx(k),tidx(k),:)));
        else
            newTrackPt.a1 = NanV;
            newTrackPt.p1 = NanV;
        end
            
        if f2idx(k)
            newTrackPt.a2 = squeeze(abs(handles.spec.S(f2idx(k),tidx(k),:)));
            newTrackPt.p2 = squeeze(angle(handles.spec.S(f2idx(k),tidx(k),:)));
        else
            newTrackPt.a2 = NanV;
            newTrackPt.p2 = NanV;
        end
        
        if f3idx(k)
            newTrackPt.a3 = squeeze(abs(handles.spec.S(f3idx(k),tidx(k),:)));
            newTrackPt.p3 = squeeze(angle(handles.spec.S(f3idx(k),tidx(k),:)));
        else
            newTrackPt.a3 = NanV;
            newTrackPt.p3 = NanV;
        end
        
        newTrackPt.id = id;
        newTrackPt.conf = -100;     % To enable detection later
        newTrackPt = computeComparisonVec(newTrackPt);

        handles.tracks = [handles.tracks newTrackPt];
    end