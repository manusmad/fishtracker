function handles = printPlot(handles)
% PRINTPLOT Print the current plot(s) to a pdf file.
%
% Prompts the user to select a filename. If one plot is visibile, print
% that plot as filename.pdf. If multiple subplots are visible, print
% each plot as filename_k.pdf.
% 
% Manu S. Madhav
% 2016
% See also EXPORT_FIG

    defFileName = [];
    if isfield(handles,'specFileName')
        [~,temp,~] = fileparts(handles.specFileName);
        defFileName = [defFileName temp];
    end
    if isfield(handles,'tracksFileName')
        [~,temp,~] = fileparts(handles.tracksFileName);
        defFileName = [defFileName '_' temp];
    end
    
    [fileName,pathName] = uiputfile([defFileName '.pdf']);
    try
        if strcmp(get(handles.singlePlotPanel,'Visible'),'on')
            export_fig(handles.hSingle,fullfile(pathName,fileName));
            handles = writeLog(handles,'Printed to %s',fileName);
        else
            for k = 1:length(handles.hSub)
                export_fig(handles.hSub(k),fullfile(pathName,sprintf('%d_%s',k,fileName)));
            end
            handles = writeLog(handles,'Printed all to k_%s',fileName);
        end
    catch
        handles = writeLog(handles,'Error printing to %s',fileName);
    end