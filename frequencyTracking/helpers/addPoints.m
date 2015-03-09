function handles = addPoints(handles,id,time,freq)
    [~,tidx] = ismember(time,handles.spec.T);
    [~,fidx] = ismember(freq,handles.spec.F);
    
    for k = 1:length(tidx)
        % Cannot have two points at the same time with the same id
        repeatIdx = [handles.tracks.t]==time(k) & [handles.tracks.id]==id;
        handles.tracks(repeatIdx) = [];
        
        nF = length(handles.spec.F);
        
        [newTrackPt.t,newTrackPt.f1,newTrackPt.a1,newTrackPt.a2,newTrackPt.a3,...
        newTrackPt.p1,newTrackPt.p2,newTrackPt.p3,newTrackPt.id] = deal(NaN);
        
        newTrackPt.t = time(k);
        newTrackPt.f1 = freq(k);
        newTrackPt.a1 = abs(handles.spec.S(fidx(k),tidx(k),:));
        newTrackPt.p1 = angle(handles.spec.S(fidx(k),tidx(k),:));

        if 2*fidx(k)<=nF
            newTrackPt.a2 = abs(handles.spec.S(fidx(k)*2,tidx(k),:));
            newTrackPt.p2 = angle(handles.spec.S(fidx(k)*2,tidx(k),:));
        end
        
        if 3*fidx(k)<=nF
            newTrackPt.a3 = abs(handles.spec.S(fidx(k)*3,tidx(k),:));
            newTrackPt.p3 = angle(handles.spec.S(fidx(k)*3,tidx(k),:));
        end
        
        newTrackPt.id = id;
        newTrackPt.conf = -100;     % To enable detection later

        handles.tracks = [handles.tracks newTrackPt];
    end