function FS_plotOverhead(type, gridCoord, tankCoord, xMean, yMean, thMean,nFish)

fishfig = figure();
colrs = distinguishable_colors(nFish);

plot(tankCoord(:,1),tankCoord(:,2),'ob'),hold on;
plot(tankCoord(:,1),tankCoord(:,2),'+b');
plot(gridCoord(:,1),gridCoord(:,2),'og');
plot(gridCoord(:,1),gridCoord(:,2),'+g');
    
if strcmp(type,'wild')  
    for fishLoop = 1:nFish
        scatter(xMean(fishLoop,:,1),yMean(fishLoop,:,1),10,colrs(fishLoop,:),'fill');
    end
     xlim([-200,200]);
            ylim([-200,200]);    
    % set(gca,'YDir','reverse');
    %  axis off
    set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[])
elseif  strcmp(type,'sim')
    scatter(trajList{fishID}(1,:),trajList{fishID}(2,:),80,'k','fill');
    for fishLoop = 1:nFish
        scatter(xMean(fishLoop,:,1),yMean(fishLoop,:,1),10,colrs(fishLoop,:),'fill');
    end

     xlim([-80,80]);
            ylim([-80,80]);    
    % set(gca,'YDir','reverse');
    %  axis off
    set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[])
else
    scatter(vidParams.tubecen(:,1),vidParams.tubecen(:,2),80,'k','fill');
    for fishLoop = 1:nFish
        scatter(xMean(fishLoop,:,1),yMean(fishLoop,:,1),10,colrs(fishLoop,:),'fill');
    end

 xlim([vidParams.tankcen(1,1),vidParams.tankcen(2,1)]);
        ylim([vidParams.tankcen(1,2),vidParams.tankcen(4,2)]);    
set(gca,'YDir','reverse');
%  axis off
set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[])
end
    
    
    