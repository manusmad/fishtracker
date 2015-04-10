function FS_plotOverhead(handles)

type        = handles.dataType;
gridCoord   = handles.gridCoord;
tankCoord   = handles.tankCoord;
xMean       = handles.xMean;
yMean       = handles.yMean;
thMean      = handles.thMean;
nFish       = handles.nFish;
vidParams   = handles.vidParams; 
stepNo      = handles.sNo;
fishSelect  = handles.fishSelect; 
xPart       = handles.xPart;
xWeight     = handles.xWeight;
nPart       = handles.nPart;

numFish     = length(fishSelect); 

axes(handles.ax_overhead)
cla
colrs = distinguishable_colors(nFish);


plot(tankCoord(:,1),tankCoord(:,2),'ob','LineWidth',1.01),hold on;
plot(tankCoord(:,1),tankCoord(:,2),'+b','LineWidth',1.01);
plot(gridCoord(:,1),gridCoord(:,2),'ok','LineWidth',1.01);
plot(gridCoord(:,1),gridCoord(:,2),'+k','LineWidth',1.01);

if strcmp(type,'wild')
    fW = 1.5;
    fL = 10;
    if handles.showTrack == 1
        for i = 1:numFish
            fishLoop = fishSelect(i);
            scatter(xMean(fishLoop,:,1),yMean(fishLoop,:,1),10,colrs(fishLoop,:),'fill');
        end
    elseif handles.showTrack == 3
        for i = 1:numFish
            fishLoop = fishSelect(i);
            scatter(xMean(fishLoop,1:stepNo,1),yMean(fishLoop,1:stepNo,1),10,colrs(fishLoop,:),'fill');
        end
    end

%     xlim([-handles.bndry,handles.bndry]);
%     ylim([-handles.bndry,handles.bndry]);  
    
    % set(gca,'YDir','reverse');
    %  axis off
elseif  strcmp(type,'sim')
    fW = 1.5;
    fL = 10;
    if handles.showVid == 1
        scatter(trajList{fishID}(1,:),trajList{fishID}(2,:),80,'k','fill');
    end
    if handles.showTrack == 1
        for i = 1:numFish
            fishLoop = fishSelect(i);
            scatter(xMean(fishLoop,:,1),yMean(fishLoop,:,1),10,colrs(fishLoop,:),'fill');
        end
    elseif handles.showTrack == 3
        for i = 1:numFish
            fishLoop = fishSelect(i);
            scatter(xMean(fishLoop,1:stepNo,1),yMean(fishLoop,1:stepNo,1),10,colrs(fishLoop,:),'fill');
        end
    end

%     xlim([-handles.bndry,handles.bndry]);
%     ylim([-handles.bndry,handles.bndry]);   
    % set(gca,'YDir','reverse');
    %  axis off
else
    fW = 3;
    fL = 20;
    if handles.showVid == 1
        scatter(vidParams.tubecen(:,1),vidParams.tubecen(:,2),80,'k','fill');
    end
    if handles.showTrack == 1
        for i = 1:numFish
            fishLoop = fishSelect(i);
            scatter(xMean(fishLoop,:,1),yMean(fishLoop,:,1),10,colrs(fishLoop,:),'fill');
        end
    elseif handles.showTrack == 3
        
        for i = 1:numFish
            fishLoop = fishSelect(i);
            scatter(xMean(fishLoop,1:stepNo,1),yMean(fishLoop,1:stepNo,1),10,colrs(fishLoop,:),'fill');
        end
    end
%     xlim([vidParams.tankcen(1,1),vidParams.tankcen(2,1)]);
%     ylim([vidParams.tankcen(1,2),vidParams.tankcen(4,2)]);    

    set(gca,'YDir','reverse');
    %  axis off
end
xlim(handles.bndryX);
ylim([handles.bndryY]);  
set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[])

amp = zeros(1,size(squeeze(handles.ampAll(1,:,handles.sNo)),2));
for fID = 1:numFish
    i = fishSelect(fID);
    if sum(isnan(squeeze(handles.ampAll(i,:,handles.sNo)))) == 0
       amp = amp + squeeze(handles.ampAll(i,:,handles.sNo));
    end   
end

if handles.showPosition == 1
    for i = 1:numFish
        fID = fishSelect(i);
        if sum(~isnan(squeeze(handles.ampAll(fID,:,handles.sNo))))
            scatter(xMean(fID,stepNo),yMean(fID,stepNo),100,colrs(fID,:),'filled')
        else
            scatter(xMean(fID,stepNo),yMean(fID,stepNo),100,colrs(fID,:))
        end       
    end
elseif handles.showAngle == 1
    for i = 1:numFish
        fID = fishSelect(i);
        if sum(~isnan(squeeze(handles.ampAll(fID,:,handles.sNo))))
            colrsMat = [colrs(fID,:);colrs(fID,:)];
        else
            colrsMat = [1 1 1;colrs(fID,:)];
        end
        plot_ellipse(fW,fL,xMean(fID,stepNo),yMean(fID,stepNo),rad2deg(thMean(fID,stepNo)-pi/2),colrsMat);
    end
end

if handles.showTime == 1
   xBound = get(gca,'xlim'); yBound = get(gca,'ylim'); 
   xText = xBound(2) - (diff(xBound)/10); yText = yBound(2) - (diff(yBound)/20);
   text(xText, yText, ['Time: ' num2str(handles.fishTime(stepNo)) 's']);
end

if handles.showHull == 1
    wt_perc = 0.9;
    for i = 1:numFish
        fID = fishSelect(i);
        convIdx = find(xWeight(fID,stepNo,:) > wt_perc*max(xWeight(fID,stepNo,:)));
        partXY = squeeze(xPart(fID,stepNo,convIdx,1:2));
        k = convhull(partXY(:,1),partXY(:,2));
        plot(partXY(k,1),partXY(k,2),'Color',colrs(fID,:))
    end
end

if handles.showParticles == 1
    t= 0:pi/10:2*pi;
    for i = 1:numFish
        fID = fishSelect(i);
        xPatch = repmat(sin(t)',1,nPart)+repmat(reshape(xPart(fID,stepNo,:,1),1,nPart),length(t),1);
        yPatch = repmat(cos(t)',1,nPart)+repmat(reshape(xPart(fID,stepNo,:,2),1,nPart),length(t),1);  
        pb=patch(xPatch,yPatch,colrs(fID,:),'EdgeColor','none');
        alpha(pb,0.08);
        hold on;
    end
end
    

    