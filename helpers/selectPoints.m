function handles = selectPoints(handles)    
    if isfield(handles,'tracks')
        handles = tracksView(handles);
        handles.hPoly = impoly(handles.hSingle);
    else
        handles = writeLog(handles,'No tracks data');
    end