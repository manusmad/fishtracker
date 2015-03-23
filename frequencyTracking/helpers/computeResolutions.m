function handles = computeResolutions(handles)
    if isfield(handles,'meta')
        nFFT = handles.params.nFFT;
        overlap = handles.params.overlap;

        nF = floor(handles.params.nFFT/2)+1;
        Fres = handles.meta.Fs / (2*nF);
        nT = fix((handles.meta.N-nFFT*overlap)/(nFFT*(1-overlap)));
        Tres = handles.meta.int*handles.meta.N / nT;
        
        set(handles.fResValTxt,'String',sprintf('%.2f',Fres));
        set(handles.tResValTxt,'String',sprintf('%.2f',Tres));
    else
        set(handles.fResValTxt,'String','[  ]');
        set(handles.tResValTxt,'String','[  ]');
    end    
    
