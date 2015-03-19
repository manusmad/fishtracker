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

axes(handles.ax_overhead)
cla
colrs = distinguishable_colors(nFish);


plot(tankCoord(:,1),tankCoord(:,2),'ob'),hold on;
plot(tankCoord(:,1),tankCoord(:,2),'+b');
plot(gridCoord(:,1),gridCoord(:,2),'og');
plot(gridCoord(:,1),gridCoord(:,2),'+g');

if strcmp(type,'wild')
    fW = 1.5;
    fL = 10;
    if handles.showTrack == 1
        for fishLoop = 1:nFish
            scatter(xMean(fishLoop,:,1),yMean(fishLoop,:,1),10,colrs(fishLoop,:),'fill');
        end
    end
     xlim([-200,200]);
            ylim([-200,200]);    
    % set(gca,'YDir','reverse');
    %  axis off
elseif  strcmp(type,'sim')
    fW = 1.5;
    fL = 10;
    if handles.showVid == 1
        scatter(trajList{fishID}(1,:),trajList{fishID}(2,:),80,'k','fill');
    end
    if handles.showTrack == 1
        for fishLoop = 1:nFish
            scatter(xMean(fishLoop,:,1),yMean(fishLoop,:,1),10,colrs(fishLoop,:),'fill');
        end
    end

     xlim([-80,80]);
            ylim([-80,80]);    
    % set(gca,'YDir','reverse');
    %  axis off
else
    fW = 3;
    fL = 20;
    if handles.showVid == 1
        scatter(vidParams.tubecen(:,1),vidParams.tubecen(:,2),80,'k','fill');
    end
    if handles.showTrack == 1
        for fishLoop = 1:nFish
            scatter(xMean(fishLoop,:,1),yMean(fishLoop,:,1),10,colrs(fishLoop,:),'fill');
        end
    end
    xlim([vidParams.tankcen(1,1),vidParams.tankcen(2,1)]);
        ylim([vidParams.tankcen(1,2),vidParams.tankcen(4,2)]);    
    set(gca,'YDir','reverse');
    %  axis off
end
 
set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[])
if handles.showPosition == 1
    for fID = 1:nFish
        if handles.showAngle == 1
            plot_ellipse(fW,fL,xMean(fID,stepNo),yMean(fID,stepNo),rad2deg(thMean(fID,stepNo)-pi/2),colrs(fID,:));
        else
            scatter(xMean(fID,stepNo),yMean(fID,stepNo),100,colrs(fID,:),'filled')
        end
    end
end
    

    