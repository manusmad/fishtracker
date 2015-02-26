function [ret,h] = plotSpectrogram(ax,T,F,Smag)

ret = 0;
colormap('hot');
caxis([0,1]);
h = imagesc(T,F,Smag,'Parent',ax);
set(ax, 'YDir', 'normal');
ret = h;