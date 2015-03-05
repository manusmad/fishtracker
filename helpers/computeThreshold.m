function handles = computeThreshold(handles)
    % Compute thresholded spectrogram whenever threshold value is changed.
    % same params as in findtracks, could either make these arguments to findTracks, or have both files pull them from a common source.
    minf1 = 200;
    maxf1 = 800;
    ratio12 = 8;
    [~,minf1idx] = min(abs(handles.spec.F-minf1));
    [~,maxf1idx] = min(abs(handles.spec.F-maxf1));
    minf1 = handles.spec.F(minf1idx);
    maxf1 = handles.spec.F(maxf1idx);
    [~,minf2idx] = min(abs(handles.spec.F-2*minf1));
    [~,maxf2idx] = min(abs(handles.spec.F-2*maxf1));
    handles.Sthresh = zeros(size(handles.Smag));
    handles.Sthresh(minf1idx:maxf1idx,:,:) = handles.Smag(minf1idx:maxf1idx,:,:)>handles.params.thresh & handles.Smag(minf2idx:2:maxf2idx,:,:)>(handles.params.thresh/ratio12);
    
