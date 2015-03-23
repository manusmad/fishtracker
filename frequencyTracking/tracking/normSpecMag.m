% Return normalized magnitude of complex spectrogram (F,T,Ch)
function Smag = normSpecMag(S)
    nF = size(S,1);
    Smag = abs(S);
    % Normalize
    m = min(Smag,[],1);
    M = max(Smag,[],1);

    Smag = (Smag - repmat(m,nF,1))./(repmat(M,nF,1)- repmat(m,nF,1));