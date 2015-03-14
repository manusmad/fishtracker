function FS_plotHeat(handles)

amp         = handles.ampAll(1,:,handles.sNo);
gridCoord   = handles.gridCoord;

divNo = 100;

xRange = max(gridCoord(:,1))- min(gridCoord(:,1));
yRange = max(gridCoord(:,2))- min(gridCoord(:,2));
xVec = min(gridCoord(:,1)):(max(gridCoord(:,1))- min(gridCoord(:,1)))/divNo:max(gridCoord(:,1));
yVec = min(gridCoord(:,2)):(max(gridCoord(:,2))- min(gridCoord(:,2)))/divNo:max(gridCoord(:,2));
[xq, yq] = meshgrid(xVec, yVec);
vq = griddata(gridCoord(:,1),gridCoord(:,2),amp,xq,yq);
vq = flipdim(vq ,1);

axes(handles.ax_heatmap); cla

imagesc(vq); hold on

imGridCoord = (divNo+1)*(gridCoord - repmat([min(gridCoord(:,1)) min(gridCoord(:,2))],size(gridCoord,1),1))./repmat([xRange yRange],size(gridCoord,1),1);
plot(imGridCoord(:,1),imGridCoord(:,2),'ow');
plot(imGridCoord(:,1),imGridCoord(:,2),'+w');

set (gca, 'xtick', [],'ytick', []);
axis tight
