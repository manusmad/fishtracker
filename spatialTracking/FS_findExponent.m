%% Pull in data 
clear
clc

% Data folder path
dataFolder = '/Users/ravi/Documents/My Folder/Projects/Grid/methodsPaperData/140406_singleFreeTrials';
% dataFolder = '/Users/ravi/Documents/My Folder/Projects/Grid/methodsPaperData/140403_singleTubeTrials';

% Extracting file names
dir_struct                  = dir([dataFolder '/freqtracks']);
[sorted_names,~]            = sortrows({dir_struct.name}');
allFile_names               = sorted_names;
tracks_search               = strfind(allFile_names,'tracks.mat');
tracksIdx                   = find(not(cellfun('isempty', tracks_search)));
tracksList                  = {allFile_names{tracksIdx}};

%% 

j = 1
% for i = 1:length(tracksList)
for i = j:j
        filename = tracksList{i};
    try
        elecTracked = open(fullfile(dataFolder,'freqtracks',tracksList{1}));
    catch ex
        errordlg(ex.getReport('basic'),'File Type Error','modal')
    end

    try
        clickFileAddr = fullfile(dataFolder,'videotracks',[filename([1:end-11]),'_clicktracks',filename([end-3:end])]);
        trackFileAddr = fullfile(dataFolder,'videotracks',[filename([1:end-11]),'_videotracks',filename([end-3:end])]);
        if exist(clickFileAddr,'file')
            vidTracked = open(clickFileAddr);
        else
            vidTracked = open(trackFileAddr);
        end
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
        display(sprintf('\nFish %d of %d',id,nFish));

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

        X = [vidTracked.fishcen vidTracked.fishang];
        
     %%
     
        distVar = (X(:,1:2) - repmat(vidTracked.gridcen(5,:),size(X,1),1));
        distThresh = 150;
        withinGridIdx = find(((distVar(:,1).^2 + distVar(:,2).^2).^0.5) < distThresh);
        
        if isfield(vidTracked,'clickTimes')
            frameTime = vidTracked.clickTimes;
        else
            frameTime = vidTracked.frameTime;
        end
        
        nFrames     = length(frameTime);
        elecTime    = fishTime + frameTime(1);
        timeIdx     = zeros(nFrames,1);
        for n = 1:nFrames
           [~,timeIdx(n)] = min(abs(elecTime - frameTime(n)));
        end
        ampVid = amp(:,timeIdx);
        
        nObsvWithinGrid = length(withinGridIdx)
        [powOpt,fopt] = FS_exponOptim(X(withinGridIdx,:),ampVid(:,withinGridIdx),gridCoord)
        fopt/nObsvWithinGrid

    end
end