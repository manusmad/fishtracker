clear

%{ 
%Sim
    tLength = 1001;
    load x; 
    trajList{1} = x(:,1:tLength);
    trajList{1}(1:2,:) = .5*(trajList{1}(1:2,:) - repmat([40;20],1,tLength));
    clear x
    load y; 
    trajList{2} = y(:,1:tLength);
    clear y
    load z;
    trajList{3} = z(:,1:tLength);
    trajList{3}(1:2,:) = .8*(trajList{3}(1:2,:) - repmat([20;40],1,tLength));
    clear z
    
    [xD,yD] = FS_testGridSim();
    gridCoord = [xD yD];
    motion = 'random'; 
    zDist = 0;
    
    fishID = 1;
    for idLoop = 1:1
        for time = 1:tLength
            X = trajList{fishID}(:,time);
%             X(1:2) = 1.4*(X(1:2) - [20;20]);
            fishCen(time,:) = X(1:2);
            fishAng(time) = X(3);
            fishAmp(:,time) = FS_AmpSimGen(X,motion,gridCoord,zDist);
        end
    end
%}

for i = 9:9
    clearvars -except i pwer
    load(['/Users/ravi/Documents/My Folder/Projects/Grid/grid/FishOnStickDay1/tracks/141111_0',sprintf('%02d',i),'_tracks_particle.mat']);
    load(['/Users/ravi/Documents/My Folder/Projects/Grid/grid/FishOnStickDay1/clips/141111_0',sprintf('%02d',i),'_tubes.mat']);

    fishAmp = ampActNormed;
    fishCen = vidParams.tubecen;
    fishAng = vidParams.tubeang;

    xD = gridCoord(:,1);
    yD = -gridCoord(:,2);
%     yD = gridCoord(:,2);  & Sim

    N = length(xD);

    cenElec = vidParams.gridcen(5,:);
    scaleFact = 6;
    
%     cenElec = [0,0];  % Sim
%     scaleFact = 1;    % Sim
    xF = (fishCen(:,1)' - cenElec(1))/scaleFact;
    yF = (fishCen(:,2)'- cenElec(2))/scaleFact;
    thF = fishAng';

    P = size(fishCen,1);

    rvec = @(X0,Y0) (repmat(xD,1,P)-repmat(X0, N,1)) + 1i*(repmat(yD,1,P)-repmat(Y0, N,1));
    relang = @(rvec0,th0) angle(rvec0)-repmat(th0,N,1);
    r = rvec(xF,yF);
    th = relang(r,thF);

    nanIdx = find(~isnan(th(1,:)));
    frameTime = vidParams.frameTime(nanIdx);
    for j = 1:length(nanIdx)
        fun=@(ab) norm(normc(cos(th(:,nanIdx(j)))./(abs(r(:,nanIdx(j))).^ab)) - normc(fishAmp(:,nanIdx(j))));
        options = optimset('MaxFunEvals',100000,'MaxIter', 100000,'TolFun',1e-16);

        ab=fminsearch(fun,0);
        coeff_pwer(j) = ab;
    end
    i
%     pwer(i-4) = ab;
% figure()
%     hist(coeff_pwer,100)
%     figure();
%     plot(xF(nanIdx),yF(nanIdx))
%     figure(); plot(xF(nanIdx))
%     hold on; scatter(1:length(coeff_pwer), coeff_pwer)
    
    f1 = figure();

    plot(vidParams.tankcen(:,1),vidParams.tankcen(:,2),'ob'),hold on;
    plot(vidParams.tankcen(:,1),vidParams.tankcen(:,2),'+b');
    plot(vidParams.gridcen(:,1),vidParams.gridcen(:,2),'og');
    plot(vidParams.gridcen(:,1),vidParams.gridcen(:,2),'+g');

    %         Plot video tracked fish

%     scatter(vidParams.tubecen(nanIdx,1),vidParams.tubecen(nanIdx,2),80,'k','fill');

    % quiver(vidParams.tubecen(:,1),vidParams.tubecen(:,2),...
    %     Lquiver*cos(vidParams.tubeang),-Lquiver*sin(vidParams.tubeang),'k','linewidth',2);
    % quiver(vidParams.tubecen(:,1),vidParams.tubecen(:,2),...
    %     Lquiver*cos(vidParams.tubeang+pi),-Lquiver*sin(vidParams.tubeang+pi),'k','linewidth',2);

    shadedErrorBar(vidParams.tubecen(nanIdx,1),vidParams.tubecen(nanIdx,2),squeeze(coeff_pwer),'-b',1) 
    shadedErrorBar(xMean(nanIdx),yMean(nanIdx),squeeze(coeff_pwer),'-r',1) 
%     scatter(xMean(nanIdx),yMean(nanIdx),80,'r','fill');

    % quiver(xMean,yMean,...
    % Lquiver*cos(thMean),...
    % -Lquiver*sin(thMean),'Color',colMat(j,:),'linewidth',2);
    % 
    % quiver(xMean,yMean,...
    %     Lquiver*cos(thMean+pi),...
    %     -Lquiver*sin(thMean+pi),'Color',colMat(j,:),'linewidth',2);

     xlim([vidParams.tankcen(1,1),vidParams.tankcen(2,1)]);
            ylim([vidParams.tankcen(1,2),vidParams.tankcen(4,2)]);    
    set(gca,'YDir','reverse');
    %  axis off
    set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[])
    
end

display('Done!')

%%

