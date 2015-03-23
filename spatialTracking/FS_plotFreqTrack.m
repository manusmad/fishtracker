function FS_plotFreqTrack(handles,freqCell)

axes(handles.ax_freqTrack)
colrs = distinguishable_colors(nFish

for i = 1:length(freqCell)
    plot(freqCell{i}(:,1),freqCell{i}(:,2),'Color',colrs(:,i));hold on
end

set(gca, 'fontsize',6)
display('Yo')