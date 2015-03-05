function handles = addLine(handles,id,time1,freq1,time2,freq2)
    if time1 > time2
        t = time2; time2=time1; time1=t;
        f = freq2; freq2=freq1; freq1=f;
    end
    
    tvec = handles.spec.T(handles.spec.T>=time1 & handles.spec.T<=time2);
    N = length(tvec);
    fvec = linspace(freq1,freq2,N);
    [~,nearestIdx] = min(abs(repmat(handles.spec.F,1,N) - repmat(fvec,length(handles.spec.F),1)));
    fvec = handles.spec.F(nearestIdx);
    handles = addPoints(handles,id,tvec,fvec);
    