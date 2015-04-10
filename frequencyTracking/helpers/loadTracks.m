function handles = loadTracks(handles)
    if isfield(handles,'tracksFilePath')
        [tracksFileName,tracksFilePath] = uigetfile([handles.tracksFilePath filesep '*.mat'],'Choose tracks file');    
    elseif isfield(handles,'lastOpenPath')
        [tracksFileName,tracksFilePath] = uigetfile([handles.lastOpenPath filesep '*.mat'],'Choose tracks file');    
    else
        [tracksFileName,tracksFilePath] = uigetfile('*.mat','Choose tracks file');
    end
    
    if tracksFileName
        try
            progressbar('Loading tracks data');
            tic;
            load(fullfile(tracksFilePath,tracksFileName),'tracks');
            runTime = toc;
            progressbar(1);
            
            handles.tracksFileName = tracksFileName;
            handles.tracksFilePath = tracksFilePath;
            handles.lastOpenPath = tracksFilePath;
            handles.tracks = tracks;

            handles = refreshPlot(handles);
            handles = populateTracksList(handles);

            handles.undo.empty();
            handles.redo.empty();
            handles = setUndoVisibility(handles);

            set(handles.tracksFileTxt,'String',tracksFileName);
            handles = writeLog(handles,'Loaded data file %s (%.2f s)',tracksFileName,runTime);  
        catch
            handles = writeLog(handles,'Could not load %s (%.2f s)',tracksFileName,runTime);
        end
    end