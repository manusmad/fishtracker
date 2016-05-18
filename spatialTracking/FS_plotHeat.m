function FS_plotHeat(handles)

type        = handles.dataType;
fishSelect  = handles.fishSelect; 
numFish     = length(fishSelect);

if strcmp(type,'tank')
    stepNo      = handles.timeIdx(handles.sNo);
else
    stepNo      = handles.sNo;
end

% if strcmp(handles.heatType,'actual')
    amp = zeros(1,size(squeeze(handles.ampAll(1,:,stepNo)),2));
    for fID = 1:numFish
        i = fishSelect(fID);
        if sum(isnan(squeeze(handles.ampAll(i,:,stepNo)))) < size(squeeze(handles.ampAll(1,:,stepNo)),2)
           amp = amp + squeeze(handles.ampAll(i,:,stepNo));
        end   
    end
% elseif strcmp(handles.heatType,'theoretical')
    ampTheoret = zeros(1,size(squeeze(handles.ampMean(1,:,handles.sNo)),2));
    for fID = 1:numFish
        i = fishSelect(fID);
        if sum(isnan(squeeze(handles.ampMean(i,:,handles.sNo)))) < size(squeeze(handles.ampMean(1,:,handles.sNo)),2)
           ampTheoret = ampTheoret + squeeze(handles.ampMean(i,:,handles.sNo));
        end   
    end
% end

% (dot(amp,ampTheoret))
if sign(dot(amp,ampTheoret)) == -1
    amp = -amp;
end

% if (dot(amp,ampTheoret)) < 15
%     amp = -amp;
% end

gridCoord   = handles.gridCoord;
tankCoord   = handles.tankCoord;
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
save('actHeat','vq')
imGridCoord = (divNo+1)*(gridCoord - repmat([min(gridCoord(:,1)) min(gridCoord(:,2))],size(gridCoord,1),1))./repmat([xRange yRange],size(gridCoord,1),1);
plot(imGridCoord(:,1),imGridCoord(:,2),'ow');
plot(imGridCoord(:,1),imGridCoord(:,2),'+w');

set (gca, 'xtick', [],'ytick', []);
axis tight

actHeat = vq;
actHeat(isnan(actHeat)) = 0;


notNanIdx = find(~isnan(ampTheoret));
vqTh = griddata(gridCoord(notNanIdx,1),gridCoord(notNanIdx,2),ampTheoret(notNanIdx),xq,yq);
vqTh = flipdim(vqTh ,1);
vqTh(isnan(vqTh)) = 0;

ssimval = ssim(vqTh,actHeat)

%%
% clc
% amp
% ampTheoret
% dot(amp,ampTheoret)
% random = 1;
%%
% axes(handles.ax_freqTrack); cla
% 
% FS_ObsvModel(squeeze([xMean(fID,i,1);yMean(fID,i,1);thMean(fID,i,1)]), gridCoord, tankCoord, handles.motion)';


