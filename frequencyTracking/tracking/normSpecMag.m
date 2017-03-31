function Smag = normSpecMag(S)
% NORMSPECMAG Return normalized magnitude of complex spectrogram
% 
% Spectrogram 'S' is a complex 3-D matrix with dimensions
% (frequency,time,channels).
%
% Manu S. Madhav
% 2016

    nF = size(S,1);
    Smag = abs(S);
    % Normalize
    m = min(Smag,[],1);
    M = max(Smag,[],1);

    Smag = (Smag - repmat(m,nF,1))./(repmat(M,nF,1)- repmat(m,nF,1));