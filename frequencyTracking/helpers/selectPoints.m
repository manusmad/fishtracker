function handles = selectPoints(handles)
% SELECTPOINTS GUI interface to select points by drawing a polygon.
%
% Manu S. Madhav
% 2016

    if isfield(handles,'tracks')
        handles = tracksView(handles);
        handles.hPoly = impoly(handles.hSingle);
    else
        handles = writeLog(handles,'No tracks data');
    end