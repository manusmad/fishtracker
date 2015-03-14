function FS_plotFreqTrack(handles)

freqCell    = handles.freqCell;
nFish       = handles.nFish;
stepNo      = handles.sNo;

axes(handles.ax_freqTrack)
cla
colrs = distinguishable_colors(nFish); 

for i = 1:length(freqCell)
    plot(freqCell{i}(:,1),freqCell{i}(:,2),'Color',colrs(i,:));hold on
end
axis tight
line([freqCell{i}(stepNo,1),freqCell{i}(stepNo,1)],ylim,'Color', 'k');
set(gca, 'fontsize',6)