function FS_plotFreqTrack(handles)

type        = handles.dataType;
fishSelect  = handles.fishSelect; 
numFish     = length(fishSelect);

freqCell    = handles.freqCell;
nFish       = handles.nFish;
if strcmp(type,'tank')
    stepNo      = handles.timeIdx(handles.sNo);
else
    stepNo      = handles.sNo;
end

axes(handles.ax_freqTrack)
cla
colrs = distinguishable_colors(nFish); 

for fID = 1:numFish
    i = fishSelect(fID);
    plot(freqCell{i}(:,1),freqCell{i}(:,2),'Color',colrs(i,:),'LineWidth',1.5);hold on
end

axis tight
line([freqCell{i}(stepNo,1),freqCell{i}(stepNo,1)],ylim,'Color', 'k');
set(gca, 'fontsize',6)