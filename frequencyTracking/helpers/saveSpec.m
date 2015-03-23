function handles = saveSpec(handles)
    if isfield(handles,'spec')
        if isfield(handles,'specFileName') && isfield(handles,'specFilePath')
            [specFileName,specFilePath] = uiputfile(fullfile(handles.specFilePath,handles.specFileName),'Save spectrogram as...');
        elseif isfield(handles,'specFilePath')
            [specFileName,specFilePath] = uiputfile([handles.specFilePath filesep '*.mat'],'Save spectrogram as...');
        elseif isfield(handles,'lastOpenPath')
            [specFileName,specFilePath] = uiputfile([handles.lastOpenPath filesep '*.mat'],'Save spectrogram as...');
        else
            [specFileName,specFilePath] = uiputfile('*.mat','Save spectrogram as...');
        end
        
        if specFileName
            progressbar('Saving spectrogram data');
            tic;
            spec = hlp_serialize(handles.spec); %#ok<NASGU>
            savefast(fullfile(specFilePath,specFileName),'spec');
            runTime = toc;
            progressbar(1);

            handles = writeLog(handles,'Saved spectrogram file %s (%.2f s)',specFileName,runTime);
            set(handles.specFileTxt,'String',specFileName);

            handles.specFileName = specFileName;
            handles.specFilePath = specFilePath;
            handles.lastOpenPath = specFilePath;
        end
    else
        handles = writeLog(handles,'No spectrogram data available');
    end