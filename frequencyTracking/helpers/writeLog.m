function handles = writeLog(handles,str,varargin)
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

