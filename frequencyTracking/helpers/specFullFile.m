function spec = specFullFile(elec,nFFT,overlap)

windadv = round(nFFT * overlap);
       
nF = floor(nFFT/2)+1;
nT = fix((size(elec.data,1)-windadv)/(nFFT-windadv));

spec.F = zeros(nF,1);
spec.T = zeros(nT,1);
spec.S = zeros(nF,nT,elec.meta.nCh);

progressbar('Computing spectrogram');
for k = 1:elec.meta.nCh;
    progressbar(k/elec.meta.nCh);
    [spec.S(:,:,k),spec.F,spec.T] = spectrogram(elec.data(:,k), nFFT, windadv, nFFT, elec.meta.Fs);     
end

% Change times to correspond to elec times
spec.T = spec.T + elec.t(1);

% This can be changed
cutoffLow = 200; %(Hz)
cutoffHigh = 2500; %(Hz)

fidx = spec.F>=cutoffLow & spec.F<=cutoffHigh;
spec.F = spec.F(fidx);
spec.S = spec.S(fidx,:,:);

spec.meta = elec.meta;