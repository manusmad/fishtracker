addpath('serialization\');
[specFileName,specFilePath] = uigetfile('*.mat','Choose spectrogram file');
if specFileName
    load(fullfile(specFilePath,specFileName),'spec');
    spec = hlp_deserialize(spec);
end


%%
Tidx = spec.T>0;% & spec.T<70;
T = spec.T(Tidx);
Fidx = spec.F<1000;%spec.F>588 & 
F = spec.F(Fidx);
S = spec.S(Fidx,Tidx,1);
Smag = abs(S);
entropy(abs(S))

%%

% S2 = fftshift(log(abs(fft2(Smag)).^2)+1);

S2 = fft2(spec.S(Fidx,:,1));

% figure(1), imshow(S2/max(S2(:)));
% figure(2), imshow(Smag/max(Smag(:)));

%%

plotSpectrogram(gca,T,F,Smag);

%% Frequency of frequencies approach

FFs = 1/diff(F(1:2));
nF = length(F);

FF = 0:(FFs/nF):(FFs/2);
nFF = length(FF);

SS = fft(spec.S(Fidx,1,1));
SSmag = abs(SS(1:nFF));
plot(FF,SSmag);

%%




