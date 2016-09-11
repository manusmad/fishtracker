function FS_plotHeat(handles)

fishSelect  = handles.fishSelect; 
numFish     = length(fishSelect);

if ~handles.particle.wildTag
    stepNo      = handles.timeIdx(handles.sNo);
else
    stepNo      = handles.sNo;
end

amp = zeros(handles.particle.nChannels,1);
for fID = 1:numFish
    i = fishSelect(fID);
    if sum(isnan(handles.particle.fish(i).ampAct(:,stepNo))) < handles.particle.nChannels
       amp = amp + handles.particle.fish(i).ampAct(:,stepNo);
    end   
end

ampTheoret = zeros(handles.particle.nChannels,1);
for fID = 1:numFish
    i = fishSelect(fID);
    if sum(isnan(handles.particle.fish(i).ampTheor(:,stepNo))) < handles.particle.nChannels
       ampTheoret = ampTheoret + handles.particle.fish(i).ampTheor(:,stepNo);
    end   
end
    
if sign(dot(amp,ampTheoret)) == -1
    amp = -amp;
end

gridCoord   = handles.gridCoord;
divNo = 100;

xRange = max(gridCoord(:,1))- min(gridCoord(:,1));
yRange = max(gridCoord(:,2))- min(gridCoord(:,2));
xVec = min(gridCoord(:,1)):(max(gridCoord(:,1))- min(gridCoord(:,1)))/divNo:max(gridCoord(:,1));
yVec = min(gridCoord(:,2)):(max(gridCoord(:,2))- min(gridCoord(:,2)))/divNo:max(gridCoord(:,2));
[xq, yq] = meshgrid(xVec, yVec);

notNanIdx = find(~isnan(amp));
vq = griddata(gridCoord(notNanIdx,1),gridCoord(notNanIdx,2),amp(notNanIdx),xq,yq);
% vq = flipdim(vq ,1);

axes(handles.ax_heatmap); cla

imagesc(vq); hold on
save('actHeat','vq')
imGridCoord = (divNo+1)*(gridCoord(:,1:2) - repmat([min(gridCoord(:,1)) min(gridCoord(:,2))],size(gridCoord,1),1))./repmat([xRange yRange],size(gridCoord,1),1);
plot(imGridCoord(:,1),imGridCoord(:,2),'ow');
plot(imGridCoord(:,1),imGridCoord(:,2),'+w');

set(gca,'YDir','reverse');
set (gca, 'xtick', [],'ytick', []);
axis tight