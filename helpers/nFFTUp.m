function handles = nFFTUp(handles)
    nfft = handles.params.nFFT;
    npow2 = 2^nextpow2(nfft);
    if npow2 == nfft
        nfft = nfft*2;
    else
        nfft = npow2;
    end
   
    handles.params.nFFT = nfft;
    set(handles.nFFTEdit,'String',num2str(nfft));