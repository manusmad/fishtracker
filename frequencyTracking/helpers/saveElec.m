function handles = saveElec(handles)
% SAVEELEC Saves electrode file
%
% Prompts user to choose a filename, and then saves the elec data structure 
% to that file.
%
% Manu S. Madhav
% 2016
% See also SAVEFAST

    if isfield(handles,'elec')
        if isfield(handles,'elecFileName') && isfield(handles,'elecFilePath')
            [elecFileName,elecFilePath] = uiputfile(fullfile(handles.elecFilePath,handles.elecFileName),'Save electrode data as...');
        elseif isfield(handles,'elecFilePath')
            [elecFileName,elecFilePath] = uiputfile([handles.elecFilePath filesep '*.mat'],'Save electrode data as...');
        elseif isfield(handles,'lastOpenPath')
            [elecFileName,elecFilePath] = uiputfile([handles.lastOpenPath filesep '*.mat'],'Save electrode data as...');
        else
            [elecFileName,elecFilePath] = uiputfile('*.mat','Save electrode data as...');
        end
        
        if elecFileName
            elec = handles.elec; %#ok<NASGU>
            tic;
            savefast(fullfile(elecFilePath,elecFileName),'elec');
            runTime = toc;

            handles = writeLog(handles,'Saved data file %s (%.2f s)',elecFileName,runTime);
            set(handles.elecFileTxt,'String',elecFileName);

            handles.elecFileName = elecFileName;
            handles.elecFilePath = elecFilePath;
            handles.lastOpenPath = elecFilePath;
        end
    else
        handles = writeLog(handles,'No electrode data loaded');
    end