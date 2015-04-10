function handles = loadSmr(handles)
    if isfield(handles,'smrFilePath')
        [smrFileName,smrFilePath] = uigetfile([handles.smrFilePath filesep '*.smr'],'Choose smr file');
    elseif isfield(handles,'lastOpenPath')
        [smrFileName,smrFilePath] = uigetfile([handles.lastOpenPath filesep '*.smr'],'Choose smr file');
    else
        [smrFileName,smrFilePath,~] = uigetfile('*.smr','Choose smr file');
    end

    if smrFileName
        try
            tic;
            elec = loadSmrFile(smrFilePath,smrFileName,handles.params.smrFilePrefix);
            runTime = toc;

            % Verify that the loaded data conforms to the rest of the data
            if compareMetaAll(handles,'elec',elec.meta)
                handles = writeLog(handles,'Parsed smr file %s, %d channels loaded. (%.2f s)',smrFileName,elec.meta.nCh,runTime);
                set(handles.elecFileTxt,'String',sprintf('Data from %s',smrFileName));

                handles.smrFileName = smrFileName;
                handles.smrFilePath = smrFilePath;
                handles.lastOpenPath = smrFilePath;
                handles.elec = elec;
                handles.meta = elec.meta;

                handles = setRanges(handles,0,elec.meta.Fs/2,elec.t(1),elec.t(end));
                handles = createSubplots(handles);
                handles = populateChannelList(handles);
                handles = computeResolutions(handles);
            else
                handles = writeLog(handles,'File %s not loaded',smrFileName);
            end
        catch
            handles = writeLog(handles,'Could not load %s (%.2f s)',smrFileName,runTime);
            progressbar(1);
        end      
    end