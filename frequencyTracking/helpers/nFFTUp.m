function handles = nFFTUp(handles)
% NFFTUP Increase the FFT length to the next power of 2
%
% Also updates the GUI with the new nFFT value
%
% Manu S. Madhav
% 2016

    nfft = handles.params.nFFT;
    npow2 = 2^nextpow2(nfft);
    if npow2 == nfft
        nfft = nfft*2;
    else
        nfft = npow2;
    end
   
    handles.params.nFFT = nfft;
    set(handles.nFFTEdit,'String',num2str(nfft));