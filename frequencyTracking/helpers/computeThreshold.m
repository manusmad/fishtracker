function handles = computeThreshold(handles)
    % Compute thresholded spectrogram whenever threshold value is changed.
    % same params as in findtracks, could either make these arguments to findTracks, or have both files pull them from a common source.
    
    if isfield(handles,'spec')
        if handles.params.minF1<handles.spec.F(1)
            handles.params.minF1 = handles.spec.F(1);
            set(handles.minF1Edit,'String',num2str(handles.params.minF1));
        end

        if handles.params.maxF1>handles.spec.F(end)
            handles.params.maxF1 = handles.spec.F(end);
            set(handles.maxF1Edit,'String',num2str(handles.params.maxF1));
        end
        
        [~,minF1Idx] = min(abs(handles.spec.F-handles.params.minF1));
        [~,maxF1Idx] = min(abs(handles.spec.F-handles.params.maxF1));
        minF1 = handles.spec.F(minF1Idx);
        maxF1 = handles.spec.F(maxF1Idx);
        [~,minf2idx] = min(abs(handles.spec.F-2*minF1));
        [~,maxf2idx] = min(abs(handles.spec.F-2*maxF1));
        handles.Sthresh = zeros(size(handles.Smag));
        handles.Sthresh(minF1Idx:maxF1Idx,:,:) = handles.Smag(minF1Idx:maxF1Idx,:,:)>handles.params.thresh & handles.Smag(minf2idx:2:maxf2idx,:,:)>(handles.params.thresh/handles.params.ratio12);
    end
    handles.params.viewMode