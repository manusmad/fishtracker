addpath('serialization\');
[specFileName,specFilePath] = uigetfile('*.mat','Choose spectrogram file');
if specFileName
    load(fullfile(specFilePath,specFileName),'spec');
    spec = hlp_deserialize(spec);
end


%%
T = spec.T;
Fidx = spec.F<1000;
F = spec.F(Fidx);
Smag = abs(spec.S(Fidx,:,1));

%%

S2 = abs(fft2(spec.S(Fidx,:,1)));
figure(1), imshow(S2/max(S2(:)));
figure(2), imshow(Smag/max(Smag(:)));

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

