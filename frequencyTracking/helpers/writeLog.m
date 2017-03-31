function handles = writeLog(handles,str,varargin)
% WRITELOG GUI interface for writing to the log in frequencyTracking
%
% Updates the string of the log textbox using the text from
% sprintf(str,varargin) and then updates the caret position of the textbox
% by low-level manipulation of the java object.
%
% Manu S. Madhav
% 2016
% See also FINDJOBJ

    logStr = get(handles.log,'String');
    if ~iscell(logStr)
        logStr = {logStr};
    end
    nLines = length(logStr);
    if (nLines+1) >= get(handles.log,'Max');
        logStr = logStr(2:end);
    end

    if ~isempty(varargin)
        str = sprintf(str,varargin{:});
    end
    
    logStr = [logStr ; str];
    set(handles.log,'String',logStr);
    
    jhEdit = findjobj(handles.log);
    jEdit = jhEdit.getComponent(0).getComponent(0);
    jEdit.setCaretPosition(jEdit.getDocument.getLength);

