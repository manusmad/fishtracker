function [ret,h] = plotSpectrogram(ax,T,F,Smag)
% PLOTSPECTROGRAM Plots time-frequency spectrogram
%
% Plots spectrogram with magnitude 'Smag' in the axis ax using time vector
% 'T' and frequency vector 'F'.
% Smag should be size length(F) x length(T).
% Returns ret=1 if successful, else ret = 0. 'h' is the returned handle to
% the plot.
%
% Manu S. Madhav
% 2016
% See also IMAGESC

ret = 0;
colormap('hot');
caxis([0,1]);
h = imagesc(T,F,Smag,'Parent',ax);
set(ax, 'YDir', 'normal');
ret = 1;