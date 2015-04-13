function FS_plotHeat(handles)

type        = handles.dataType;
fishSelect  = handles.fishSelect; 
numFish     = length(fishSelect);

if strcmp(type,'tank')
    stepNo      = handles.timeIdx(handles.sNo);
else
    stepNo      = handles.sNo;
end

amp = zeros(1,size(squeeze(handles.ampAll(1,:,stepNo)),2));
for fID = 1:numFish
    i = fishSelect(fID);
    if sum(isnan(squeeze(handles.ampAll(i,:,stepNo)))) < size(squeeze(handles.ampAll(1,:,stepNo)),2)
       amp = amp + squeeze(handles.ampAll(i,:,stepNo));
    end   
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
vq = flipdim(vq ,1);

axes(handles.ax_heatmap); cla

imagesc(vq); hold on

imGridCoord = (divNo+1)*(gridCoord - repmat([min(gridCoord(:,1)) min(gridCoord(:,2))],size(gridCoord,1),1))./repmat([xRange yRange],size(gridCoord,1),1);
plot(imGridCoord(:,1),imGridCoord(:,2),'ow');
plot(imGridCoord(:,1),imGridCoord(:,2),'+w');

set (gca, 'xtick', [],'ytick', []);
axis tight
