%% Pull in data 
clear
clc

% Data folder path
dataFoldCell{1} = '/Users/ravi/Documents/My Folder/Projects/Grid/methodsPaperData2/140406_singleFreeTrials';
% dataFoldCell{2} = '/Users/ravi/Documents/My Folder/Projects/Grid/methodsPaperData2/140403_singleTubeTrials';
% dataFoldCell{3} = '/Users/ravi/Documents/My Folder/Projects/Grid/methodsPaperData2/141111_tubeOnStick';
% dataFoldCell{4} = '/Users/ravi/Documents/My Folder/Projects/Grid/methodsPaperData2/140422_threeFreeTrials';
% dataFoldCell{5} = '/Users/ravi/Documents/My Folder/Projects/Grid/methodsPaperData2/140417_threeTubeTrials';


% distThreshVec = -60:6:60;
distThreshVec = 0;
ThreeFishMap = [3 2 1;
                3 2	1;
                3 2	1;
                3 2	1;
                3 2	1;
                3 2	1;
                3 2	1;
                3 2	1;
                3 1	2;
                3 1	2;
                3 1	2;
                3 1	2;
                3 2	1];
            
ThreeTubeMap = [2 3 1; %1
                2 1 3; %2
                2 1 3; %3 
                2 1 3; %4
                2 1 3; %5
                2 3 1; %6
                2 3 1; %7
                2 3 1; %8
                2 3 1; %9
                2 3 1; %10
                2 3 1; %11
                2 3 1; %12
                2 1 3; %13
                2 1 3; %14
                2 1 3; %15
                2 3 1; %16
                2 1 3; %17
                2 1 3; %18
                2 3 1; %19
                1 2 3; %20
                3 1 2; %21
                3 2 1; %22
                3 2 1; %23
                1 2 3; %24
                3 2 1; %25
                2 1 3; %26
                1 2 3; %27
                3 2 1; %28
                3 2 1; %29
                2 1 3; %30
                3 2 1; %31
                3 2 1; %32
                3 2 1; %33
                1 2 3; %34
                3 2 1; %35
                2 3 1; %36
                2 3 1; %37
                2 3 1; %38
                2 3 1; %39
                2 1 3; %40
                ];
elecToVid = [];            
for i = 1:length(ThreeTubeMap)
    x = ThreeTubeMap(i,:);
    for j = 1:3
        elecToVid(i,j) = find(x ==j);
    end
end    

% refElecMat = nchoosek(1:9,2);
refElecMat = [1 1];
for distLoop = 1:length(distThreshVec)
        dataX = cell(8,1);
        dataY = cell(8,1);
        dataZ = cell(8,1);
        allDataX = [];
        allDataY = [];
        allDataZ = [];
    for refLoop = 1:size(refElecMat,1)
        refLoop
        refElec = refElecMat(refLoop,:);
%         display(sprintf('\n %d of %d',distLoop,length(distThreshVec)));
        distThresh = distThreshVec(distLoop);
        for dataFoldLoop = 1:length(dataFoldCell)
            if ~isempty(dataFoldCell{dataFoldLoop})
                [~,foldername,~] = fileparts(dataFoldCell{dataFoldLoop});
                if strcmp(foldername, '140417_threeTubeTrials')
                    fishMap = elecToVid;
                elseif strcmp(foldername, '140422_threeFreeTrials')
                    fishMap = ThreeFishMap;
                end
                [~,name,~] =fileparts(dataFoldCell{dataFoldLoop});
                name = regexprep(name,'_',' ');
            end
            dataFolder                  = dataFoldCell{dataFoldLoop};
            % Extracting file names
            dir_struct                  = dir([dataFolder '/freqtracks']);
            [sorted_names,~]            = sortrows({dir_struct.name}');
            allFile_names               = sorted_names;
            tracks_search               = strfind(allFile_names,'tracks.mat');
            tracksIdx                   = find(not(cellfun('isempty', tracks_search)));
            tracksList                  = {allFile_names{tracksIdx}};
            colVec = distinguishable_colors(9*length(tracksList));
            for dataIdx = 1:length(tracksList) 
    %         dataList = [5 6 7 8 9];
    %         for dataIdx = 1:length(dataList)
                    dataList = 1:length(tracksList);
                    filename = tracksList{dataList(dataIdx)};

                try
                    elecTracked = open(fullfile(dataFolder,'freqtracks',tracksList{dataList(dataIdx)}));
                catch ex
                    errordlg(ex.getReport('basic'),'File Type Error','modal')
                end

                try
                    trackFileAddr = fullfile(dataFolder,'videotracks',[filename([1:end-11]),'_videotracks',filename([end-3:end])]);
                    vidTracked = open(trackFileAddr);
                catch ex
                    errordlg(ex.getReport('basic'),'File Type Error','modal')
                end

                scaleFact   = 6;

                gridTemp            = (vidTracked.gridcen-repmat(vidTracked.gridcen(5,:),9,1))/scaleFact;
                gridCoord           = [gridTemp(:,1) -gridTemp(:,2)];
                tankTemp            = (vidTracked.tankcen-repmat(vidTracked.gridcen(5,:),4,1))/scaleFact;
                tankCoord           = [tankTemp(1:2,:);tankTemp(4:-1:3,:);tankTemp(1,:)];


                fishHist    = elecTracked.tracks;
                fishID      = unique([fishHist.id]);
                nFish       = length(fishID);
                nCh         = size(fishHist(1).a1,1);
                fishTime    = sort(unique([fishHist.t]),'ascend');
                [~,sortIdx] = sort([fishHist.t],'ascend');
                fishHist    = fishHist(sortIdx);
                nTime = length(fishTime);
                angThresh = 0;

                for id = 1:nFish
            %         display(sprintf('\nFish %d of %d',id,nFish));

                    p1 = [fishHist(find([fishHist.id] == fishID(id))).p1];
                    for i = 1:nTime
                        p2 = p1(:,i);
                        if sum(isnan(p1(:,i))) < (nCh - 4)                           
                            nanVec          = isnan(p1(:,i));
                            p1Def           = p1(~nanVec,i);
                            clustVec        = circ_clust(p1Def',2);

                            c1Idx       = find(clustVec==1);
                            c1          = p1Def(c1Idx);
                            c1Med       = circ_median(c1);

                            c2Idx       = find(clustVec==2);
                            c2          = p1Def(c2Idx);
                            c2Med       = circ_median(c2);

                            p2 = zeros(nCh,1);
                            if abs(rad2deg(circ_dist(c1Med,c2Med))) >= angThresh
                                p1Def(c1Idx) = 0;
                                p1Def(c2Idx) = pi;
                            else
                                p1Def(:)     = 0;
                            end
                            p2(~nanVec) = p1Def;
                            p2(nanVec) = NaN;
                        end 
                        p1(:,i) = p2;            
                    end
                    amp = ([fishHist([fishHist.id] == fishID(id)).a1]).*sign(cos(p1));    
                    % Make maximum amplitude positive
                    [~,Midx] = max(abs(amp));

                    amp = amp.*repmat(sign(amp(sub2ind(size(amp),Midx,1:size(amp,2)))),size(amp,1),1);

                    if dataFoldLoop >= 4
                        X = [vidTracked.fishCen(:,:,fishMap(dataIdx,id)) vidTracked.fishTheta(:,fishMap(dataIdx,id))];
                    else
                        X = [vidTracked.fishCen vidTracked.fishTheta];
                    end

%                     refElec = [4 7];
                    distVar = (X(:,1:2) - repmat(vidTracked.gridcen(refElec(1),:),size(X,1),1));
                    distCen = ((distVar(:,1).^2 + distVar(:,2).^2).^0.5);
                    P = size(X,1);
                    rcen    = (repmat(vidTracked.gridcen(refElec(1),1),P,1)-X(:,1)) + 1i*(repmat(vidTracked.gridcen(refElec(1),2),P,1)-X(:,2));
                    relcenang  = angle(rcen)- X(:,3);
                    rend    = (repmat(vidTracked.gridcen(refElec(2),1),P,1)-X(:,1)) + 1i*(repmat(vidTracked.gridcen(refElec(2),2),P,1)-X(:,2));
                    distEnd = abs(rend);
                    relendang  = angle(rend)- X(:,3);

                    withinGridIdx = find(X(:,1) < max(vidTracked.gridcen(:,1)) + distThresh & X(:,1) > min(vidTracked.gridcen(:,1))- distThresh ...
                                        & X(:,2) < max(vidTracked.gridcen(:,2))+ distThresh & X(:,2) > min(vidTracked.gridcen(:,2))- distThresh);
                    frameTime = vidTracked.frameTime;

                    % Check if elec and click synchronized
                    nFrames     = length(frameTime);
                    elecTime    = fishTime;

                    timeIdx     = zeros(nFrames,1);

                    for n = 1:nFrames
                       [~,timeIdx(n)] = min(abs(elecTime - frameTime(n)));
                    end
                    ampVid = (amp(:,timeIdx));

                    xD = vidTracked.gridcen(:,1);
                    yD = vidTracked.gridcen(:,2);

                    elecList = setdiff(1:9,refElec);
                    for iElec = 1:length(elecList)
                        nElec = elecList(iElec);
                        rvec    = (repmat(xD(nElec),P,1)-X(:,1)) + 1i*(repmat(yD(nElec),P,1)-X(:,2));
                        relang  = angle(rvec)- X(:,3);

                        distVec = (X(:,1:2) - repmat(vidTracked.gridcen(nElec,:),size(X,1),1));
                        distElec = ((distVec(:,1).^2 + distVec(:,2).^2).^0.5);
                        dataX{iElec} = [dataX{iElec}; distElec(withinGridIdx) distCen(withinGridIdx) distEnd(withinGridIdx) cos(relang(withinGridIdx)) cos(relcenang(withinGridIdx)) cos(relendang(withinGridIdx))];
                        dataY{iElec} = [dataY{iElec}; ((ampVid(nElec,withinGridIdx) - ampVid(refElec(1),withinGridIdx))./(ampVid(refElec(2),withinGridIdx) - ampVid(refElec(1),withinGridIdx)))'];
                        allDataX = [allDataX; distElec(withinGridIdx) distCen(withinGridIdx) distEnd(withinGridIdx) cos(relang(withinGridIdx)) cos(relcenang(withinGridIdx)) cos(relendang(withinGridIdx))];
%                         allDataY = [allDataY; ((ampVid(nElec,withinGridIdx) - ampVid(refElec(1),withinGridIdx))./(ampVid(refElec(2),withinGridIdx) - ampVid(refElec(1),withinGridIdx)))'];                  
                        allDataY = [allDataY; ((ampVid(nElec,withinGridIdx) - ampVid(refElec(1),withinGridIdx)))'];                  
                    end
                end
            end
        end
    end
%         modelfun = @(b,x)((x(:,4)./x(:,1).^b(1) - x(:,5)./x(:,2).^b(1))./(x(:,6)./x(:,3).^b(1) - x(:,5)./x(:,2).^b(1)));
        modelfun = @(b,x)((x(:,4)./x(:,1).^b(1) - x(:,5)./x(:,2).^b(1)));
%     beta0 = [1];
%     opts = statset('TolFun',1e-30,'MaxIter',100000,'TolX',1e-30);
%     mdl = fitnlm(allDataX,(allDataY),modelfun,beta0,'Options',opts)
end

%%

expVar = 0:0.01:3;
clear meanVec
for i = 1:length(expVar)
    stdVar = nanstd(modelfun(expVar(i),allDataX)-allDataY);
    sumStdIdx = find(abs(modelfun(expVar(i),allDataX)-allDataY)<2*stdVar);
    errorVec = modelfun(expVar(i),allDataX)-allDataY;
    meanVec(i) = nanmean(errorVec(sumStdIdx));
%     stdVec(i)  = nanstd(modelfun(expVar(i),allDataX)-allDataY);
%     for j = 1:length(elecList)
%         meanVec(i,j) = nanmean(modelfun(expVar(i),dataX{j})-dataY{j});
%     end
end
%%
figure();plot(repmat(expVar,size(meanVec,2),1)',ndnanfilter(abs(meanVec),'rectwin',3))
% ylim([0 10])
% figure();plot(expVar,stdVec)
% ylim([0 100])

%%
%     modelfun = @(b,x)((x(:,4)./x(:,1).^b(1) - x(:,5)./x(:,2).^b(1))./(x(:,6)./x(:,3).^b(1) - x(:,5)./x(:,2).^b(1)));
%     beta0 = [0.6];
%     opts = statset('TolFun',1e-30,'MaxIter',100000,'TolX',1e-30);
%     mdl = fitnlm(allDataX,(allDataY),modelfun,beta0,'Options',opts)
%%


% modelfun = @(b,x)((x(:,4)./x(:,1).^b(1) - x(:,5)./x(:,2).^b(1))./(x(:,6)./x(:,3).^b(1) - x(:,5)./x(:,2).^b(1)));
% beta0 = [1];
% opts = statset('TolFun',1e-30,'MaxIter',100000,'TolX',1e-30);
% for i = 1:length(elecList)
%     i
%     mdl = fitnlm(dataX{i},dataY{i},modelfun,beta0,'Options',opts)
% end
    
%%
%{
figure();
for i = 1:9
    plot(distThreshVec,fitParamElec(:,i,1));
    hold on;
end

figure();plot(distThreshVec,fitParamOverall(:,1));
% xlim([150 500])
% line([190,190],ylim,'Color', 'k');
% xlabel('Distance from center electrode');ylabel('Fitted Exponent')
% title('The black bar is the inter electrode pixel distance')
set(gca,'Color','w')
%}