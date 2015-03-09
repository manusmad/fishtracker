function handles = refreshPlot(handles)
    plotFlag = 0;
    % Clear selections
    if isfield(handles,'hPoly');
        handles = rmfield(handles,'hPoly');
    end
    
    if isfield(handles,'meta')
        if strcmp(handles.params.viewMode,'Threshold')
            axes(handles.hSingle);
            cla(handles.hSingle);
            hold(handles.hSingle,'on');

            if isfield(handles,'spec')
                if strcmp(handles.params.viewChannel,'Single')
                    chan = get(handles.channelListBox,'Value');
                    chan = chan(1);
                    cla(handles.hSingle);
                    [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSingle,handles.spec.T,handles.spec.F,handles.Sthresh(:,:,chan));
                elseif strcmp(handles.params.viewChannel,'Mean')
                    cla(handles.hSingle);
                    [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSingle,handles.spec.T,handles.spec.F,sum(handles.Sthresh,3)>1);
                elseif strcmp(handles.params.viewChannel,'All')
                    for k = 1:handles.meta.nCh      % For each channel
                        cla(handles.hSub(k));
                        [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSub(k),handles.spec.T,handles.spec.F,handles.Sthresh(:,:,k));
                        
                        axis(handles.hSub(k),...
                        [handles.params.rangeT1,handles.params.rangeT2,handles.params.rangeF1,handles.params.rangeF2]);
                        
                        % Set callback function for image clicking
                        set(handles.hSpec,'ButtonDownFcn',{@subFigClickCallBack,handles});
                    end
                    
                    % Indicate elected
                    chan = get(handles.channelListBox,'Value');
                    for k = 1:length(chan)
                        x = get(handles.hSub(chan(k)),'XLim');
                        y = get(handles.hSub(chan(k)),'YLim');
                        hold(handles.hSub(chan(k)),'on');
                        plot(handles.hSub(chan(k)),[x(1) x(2) x(2) x(1) x(1)],[y(1) y(1) y(2) y(2) y(1)],'-y','LineWidth',5);
                        hold(handles.hSub(chan(k)),'off');
                    end                    
                end
            end

            axis(handles.hSingle,...
                [handles.params.rangeT1,handles.params.rangeT2, ...
                handles.params.rangeF1,handles.params.rangeF2]);
            hold(handles.hSingle,'off');

        elseif strcmp(handles.params.viewMode,'Normal')

            % Single channel
            if strcmp(handles.params.viewChannel,'Single')
                cla(handles.hSingle);
                hold(handles.hSingle,'on');

                % Plot spectrogram
                if handles.params.viewSpec && isfield(handles,'spec')
                    chan = get(handles.channelListBox,'Value');
                    chan = chan(1);
                    [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSingle,handles.spec.T,handles.spec.F,handles.Smag(:,:,chan));
                end

                % Plot tracks
                if handles.params.viewTracks && isfield(handles,'tracks')
                    if handles.params.trackHighlight
                        selTracks = get(handles.tracksListBox,'Value');
                    else
                        selTracks = [];
                    end
                    [plotFlag,handles.hTracks] = plotTracks(handles.hSingle,handles.tracks,selTracks);
                end

                axis(handles.hSingle,...
                    [handles.params.rangeT1,handles.params.rangeT2, ...
                    handles.params.rangeF1,handles.params.rangeF2]);
                hold(handles.hSingle,'off');

            elseif strcmp(handles.params.viewChannel,'Mean')
                cla(handles.hSingle);
                hold(handles.hSingle,'on');

                % Plot spectrogram
                if handles.params.viewSpec && isfield(handles,'spec')
                    [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSingle,handles.spec.T,handles.spec.F,mean(handles.Smag,3));
                end

                % Plot tracks
                if handles.params.viewTracks  && isfield(handles,'tracks')
                    if handles.params.trackHighlight
                        selTracks = get(handles.tracksListBox,'Value');
                    else
                        selTracks = [];
                    end
                    [plotFlag,handles.hTracks] = plotTracks(handles.hSingle,handles.tracks,selTracks);
                end

                axis(handles.hSingle,...
                    [handles.params.rangeT1,handles.params.rangeT2, ...
                    handles.params.rangeF1,handles.params.rangeF2]);
                hold(handles.hSingle,'off');    

            elseif strcmp(handles.params.viewChannel,'All')
                for k = 1:handles.meta.nCh      % For each channel
                    cla(handles.hSub(k));
                    hold(handles.hSub(k),'on');

                    % Plot spectrogram
                    if handles.params.viewSpec && isfield(handles,'spec')
                        [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSub(k),handles.spec.T,handles.spec.F,handles.Smag(:,:,k));
                        
                        % Set callback function for image clicking
                        set(handles.hSpec,'ButtonDownFcn',{@subFigClickCallBack,handles});
                    end

                    % Plot tracks
                    if handles.params.viewTracks && isfield(handles,'tracks')
                        if handles.params.trackHighlight
                            selTracks = get(handles.tracksListBox,'Value');
                        else
                            selTracks = [];
                        end
                        [plotFlag,handles.hTracks] = plotTracks(handles.hSub(k),handles.tracks,selTracks);
                    end

                    axis(handles.hSub(k),...
                    [handles.params.rangeT1,handles.params.rangeT2, ...
                    handles.params.rangeF1,handles.params.rangeF2]);
                    hold(handles.hSub(k),'off');
                end
                
                % Indicate selected
                chan = get(handles.channelListBox,'Value');
                for k = 1:length(chan)
                    x = get(handles.hSub(chan(k)),'XLim');
                    y = get(handles.hSub(chan(k)),'YLim');
                    hold(handles.hSub(chan(k)),'on');
                    plot(handles.hSub(chan(k)),[x(1) x(2) x(2) x(1) x(1)],[y(1) y(1) y(2) y(2) y(1)],'-y','LineWidth',5);
                    hold(handles.hSub(chan(k)),'off');
                end
            end
        end
    else
        set(handles.singlePlotPanel,'Visible','on');
        set(handles.multiPlotPanel,'Visible','off');
        axes(handles.hSingle);
        cla(handles.hSingle);
    end
    
    if ~plotFlag
        handles = writeLog(handles,'Nothing to refresh');
    end
      
