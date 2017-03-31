function fish = findTracks(S,F,T,minF1,maxF1,ratio12,thresh)
% FINDTRACKS Main frequency tracking function
% 
% Implementation of the core algorithm for frequency tracking of electric
% fish.
% 
% Inputs:
%   Spectrogram matrix 'S' at equally spaced frequencies 'F' and equally
%   spaced times 'T'. size(S) = [length(F), length(T)].
%   Algorithm looks for tracks with fundamentals with frequencies between 
%   'minF1' and 'maxF1', where the ratio between the ampltitudes is at
%   least 'ratio12'. Each peak must also be above threshold 'thresh' in the
%   fundamental, and thresh/ratio12 in the second harmonic.
%
% Returns structure 'fish' which is the tracked frequency structure.
%
% Manu S. Madhav
% 2016

dF = F(2)-F(1);
dT = T(2)-T(1);

normSmag = normSpecMag(S);
Smag = abs(S);
Sphs = angle(S);
[~,nT,nCh] = size(S);

% Default values for parameters
if nargin<4 || isempty(minF1) 
    minF1 = 200;
elseif nargin<5 || isempty(maxF1)
    maxF1 = 800;
elseif nargin<6 || isempty(ratio12)
    ratio12 = 8;
elseif nargin<7 || isempty(thresh)
    thresh = 0.5;
end


progressbar('Finding Signatures...','Clustering Candidates...','Tracing Tracks...');

%% Find signatures (electrode-by-electrode fft peak analysis)
tic;

Fsep = dF;
sigs = cell(nT,1);
parfor_progress(nT);
parfor tstep = 1:nT    
    tSigs = struct('ch',cell(1),'t',cell(1),'f1',cell(1),...
    'a1',cell(1),'a2',cell(1),...
    'p1',cell(1),'p2',cell(1));
    nSigs = 0;
    
    za = squeeze(Smag(:,tstep,:));
    zm = squeeze(Smag(:,tstep,:));
    zp = squeeze(Sphs(:,tstep,:));
  
    for c = 1:nCh       
        % Find peaks of all above second harmonic range
        [pks,locs] = findpeaks(za(:,c),'SORTSTR','descend','MINPEAKHEIGHT',thresh/ratio12,'MINPEAKPROMINENCE',thresh/(ratio12*2));
        
        % Sort by frequency
        [locs,idx] = sort(locs,'ascend');
        pks = pks(idx);

        % Locate fundamentals with significant second harmonics
        while(~isempty(locs))
            % If this is the fundamental, find all the peaks at harmonics
            f1 = F(locs(1));
            nHarm = 2;%floor(F(end)/f1);
            harmIdx = false(length(locs),nHarm);
            for harm = 1:nHarm             
                harmIdx(:,harm) = abs(F(locs)-harm*f1) <= Fsep;
            end
            
            if f1>minF1 && f1<maxF1 %&& nHarm>=2
                f1pks = pks(harmIdx(:,1));
                f1locs = locs(harmIdx(:,1));
                [a1,a1idx] = max(f1pks);
                
                f2pks = pks(harmIdx(:,2));
                f2locs = locs(harmIdx(:,2));
                [a2,a2idx] = max(f2pks);
                
                if ~isempty(a2)
                    if  a1>=thresh && a2>=(thresh/ratio12)
                        nSigs = nSigs+1;

                        tSigs(nSigs).f1 = F(f1locs(a1idx));

                        tSigs(nSigs).a1 = zm(f1locs(a1idx),c);
                        tSigs(nSigs).p1 = zp(f1locs(a1idx),c);

                        tSigs(nSigs).a2 = zm(f2locs(a2idx),c);
                        tSigs(nSigs).p2 = zp(f2locs(a2idx),c);

                        tSigs(nSigs).ch = c;
                        tSigs(nSigs).t = T(tstep);                
                    end
                end
            end
            
            elimIdx = logical(sum(harmIdx,2));
            pks(elimIdx) = [];
            locs(elimIdx) = []; 
        end
    end
    if length(tSigs)~=1 || ~isempty(tSigs.t)
        sigs{tstep} = tSigs;
    end
    parfor_progress;
end

sigs = [sigs{:}];
parfor_progress(0);
progressbar(1,[],[]);

toc;

if isempty(sigs)
    warning('No signatures found')
    return;
end

%% UNCOMMENT to plot all signatures
% figure,clf, hold on;
% colormap('hot');
% caxis([0,1]);
% 
% imagesc(T,F,normSmag(:,:,1));
% % plot([sigs([sigs.ch]==5).t],[sigs([sigs.ch]==5).f1],'.g');
% plot([sigs.t],[sigs.f1],'.g');
% 
% xlim([T(1),T(end)]);
% ylim([minF1,maxF1]);
% set(gca, 'YDir', 'normal');
% hold off;

%% Find candidates
tic;
cand = cell(nT,1);
   
parfor_progress(nT);
for tstep = 1:nT
    tCand = struct('t',cell(1),'f1',cell(1),...
        'a1',cell(1),'a2',cell(1),'a3',cell(1),...
        'p1',cell(1),'p2',cell(1),'p3',cell(1));
    nCand = 0;
    zm = squeeze(Smag(:,tstep,:));
    zp = squeeze(Sphs(:,tstep,:));
    
    tSigs = sigs([sigs.t]==T(tstep));

    if ~isempty([tSigs.f1])
        % There should not be peaks in adjacent frequency bins. If so,
        % combine them.
        [~,fidx] = sort([tSigs.f1]);
        tSigs = tSigs(fidx);
        
        uF1 = unique([tSigs.f1]);
        
        ddF1 = diff([0,diff(uF1)<3*dF,0]);        
        fBlockStart = find(ddF1==1);
        fBlockEnd = find(ddF1==-1);
        nFBlocks = length(fBlockStart);
        
        f1Count = ones(size(uF1));
        
        % Resolve continuous blocks
        for k = 1:nFBlocks
            nCand = nCand+1;
            tCand(nCand).t = T(tstep);
            
            tSigsF = tSigs(ismember([tSigs.f1],uF1(fBlockStart(k):fBlockEnd(k))));
            [~,maxidx] = max([tSigsF.a1]);
            
            tCand(nCand).f1 = tSigsF(maxidx).f1;
            
            [~,f1idx] = min(abs(F-tCand(nCand).f1));
            [~,f2idx] = min(abs(F-tCand(nCand).f1*2));
            [~,f3idx] = min(abs(F-tCand(nCand).f1*3));
            
            tCand(nCand).a1 = squeeze(zm(f1idx,:))';
            tCand(nCand).a2 = squeeze(zm(f2idx,:))';
            tCand(nCand).a3 = squeeze(zm(f3idx,:))';

            tCand(nCand).p1 = squeeze(zp(f1idx,:))';
            tCand(nCand).p2 = squeeze(zp(f2idx,:))';
            tCand(nCand).p3 = squeeze(zp(f3idx,:))';
            
            f1Count(fBlockStart(k):fBlockEnd(k)) = 0;
        end
        
        uF1 = uF1(logical(f1Count));
        
        for k = 1:length(uF1)
            if sum([tSigs.f1]==uF1(k))>1
                nCand = nCand+1;
                tCand(nCand).t = T(tstep);
                tCand(nCand).f1 = uF1(k);

                [~,f1idx] = min(abs(F-tCand(nCand).f1));
                [~,f2idx] = min(abs(F-tCand(nCand).f1*2));
                [~,f3idx] = min(abs(F-tCand(nCand).f1*3));
                
                tCand(nCand).a1 = squeeze(zm(f1idx,:))';
                tCand(nCand).a2 = squeeze(zm(f2idx,:))';
                tCand(nCand).a3 = squeeze(zm(f3idx,:))';
                
                tCand(nCand).p1 = squeeze(zp(f1idx,:))';
                tCand(nCand).p2 = squeeze(zp(f2idx,:))';
                tCand(nCand).p3 = squeeze(zp(f3idx,:))';
            end
        end
    else
        fprintf('No signatures at time %2.2f\n',T(tstep));
    end   
    
    if length(tCand)~=1 || ~isempty(tCand.t)
        cand{tstep} = tCand;
    end
    parfor_progress;
end

cand = [cand{:}];

parfor_progress(0);
progressbar([],1,[]);
toc;

if isempty(cand)
    warning('No candidates found')
    return;
end

%% UNCOMMENT to plot all candidates
% figure,clf, hold on;
% colormap('hot');
% caxis([0,1]);
% 
% imagesc(T,F,normSmag(:,:,1));
% plot([sigs.t],[sigs.f1],'.g');
% 
% plot([cand.t],[cand.f1],'.m');
% 
% xlim([T(1),T(end)]);
% ylim([minF1,maxF1]);
% set(gca, 'YDir', 'normal');
% hold off;
    
%% Step 1: Find all 1-step connections between candidates and add them as tracks
disp('Finding fish...');
tic;

cand = computeComparisonVec(cand);
thresh = 200;
tracks = [];

n = round(5/dT);

tCandIdx = cell(nT,1);
for k = 1:nT
    tCandIdx{k} = find([cand.t]==T(k));
end

for j = 1:n
    fprintf('\nLooking for %d-connected tracks\n',j);
    tic;
    for k = 1:(nT-j)
        cand1idx = tCandIdx{k};
        cand2idx = tCandIdx{k+j};

        if ~isempty(tracks)
            cand1idx = cand1idx(~ismember(cand1idx,tracks(1,:)));
            cand2idx = cand2idx(~ismember(cand2idx,tracks(2,:)));
        end
        
        if ~isempty(cand1idx) && ~isempty(cand2idx)
            [R,C] = matchHungarian(cand(cand1idx),cand(cand2idx),thresh);
            
            tracks = [tracks,[cand1idx(R);cand2idx(C)]];
        end
    end
    toc;
    fprintf('%d tracks found so far\n',length(tracks))
end

% Step 2: Join all the tracks with the same end points
tracks2 = mat2cell(tracks,2,ones(1,size(tracks,2)));

k = 1;
flag = 1;

trackStart = cellfun(@(x) x(1),tracks2);

while k<length(tracks2)
    while flag
        nextIdx = find(tracks2{k}(end)==trackStart(k+1:end),1);
        flag = ~isempty(nextIdx);
        if flag
            tracks2{k} = [tracks2{k}(1:end-1);tracks2{nextIdx+k}];
            tracks2(nextIdx+k) = [];
            trackStart(nextIdx+k) = [];
        end
    end
    k = k+1;
    flag = 1;
end

% Step3: Try to combine tracks together with distance metric
tracks3 = tracks2;

k = 1;
flag = 1;

while k<length(tracks3)
    while flag
        dist = cellfun(@(x) pdist2(cand(tracks3{k}(end)).vec',cand(x(1)).vec') + (0.5/dT)*abs(cand(tracks3{k}(end)).t - cand(x(1)).t),tracks3(k+1:end));
        fdist = cellfun(@(x) pdist2(cand(tracks3{k}(end)).f1',cand(x(1)).f1'),tracks3(k+1:end));
        lt = cellfun(@(x) cand(tracks3{k}(end)).t < cand(x(1)).t,tracks3(k+1:end));
        nextIdx = find(dist<thresh & fdist<1 & lt,1);
        flag = ~isempty(nextIdx);
        if flag
            tracks3{k} = [tracks3{k}(1:end-1);tracks3{nextIdx+k}];
            tracks3(nextIdx+k) = [];
        end
    end
    k = k+1;
    flag = 1;
end

% Delete tiny tracks
% len = cellfun(@(x) length(x),tracks3);
% tracks3(len<(1/dT)) = [];

% Arrange into structure
fish = [];
for k = 1:length(tracks3)
    trackCands = cand(tracks3{k});
    [trackCands.id] = deal(k);
    [trackCands.conf] = deal(length(trackCands));
    fish = [fish,trackCands];
end

%% UNCOMMENT to plot all tracks
% figure,clf, hold on;
% colormap('hot');
% caxis([0,1]);
% 
% imagesc(T,F,normSmag(:,:,1));
% 
% for k = 1:length(tracks)
%     plot([cand(tracks(:,k)).t],[cand(tracks(:,k)).f1],'.-','MarkerSize',20,'LineWidth',1);
% end
%
% col = distinguishable_colors(length(tracks2),'k');
% for k = 1:length(tracks2)
%     plot([cand(tracks2{k}).t],[cand(tracks2{k}).f1],'.-','MarkerSize',20,'LineWidth',1,'Color',col(k,:));
% end
% 
% col = distinguishable_colors(length(tracks3),'k');
% for k = 1:length(tracks3)
%     plot([cand(tracks3{k}).t],[cand(tracks3{k}).f1],'.-','MarkerSize',20,'LineWidth',1,'Color',col(k,:));
% end
% 
% xlim([T(1),T(end)]);
% ylim([minF1,maxF1]);
% set(gca, 'YDir', 'normal');
% hold off;

%% Before returning, re-assign and sort ids by mean frequency
if ~isempty(fish)
    uId = unique([fish.id]);
    nId = length(uId);
    meanF = zeros(nId,1);

    for k = 1:nId
        idx = [fish.id]==uId(k);
        meanF(k) = mean([fish(idx).f1]);
    end

    [~,fidx] = sort(meanF,'descend');
    fish2 = fish;
    for k = 1:nId
        idx = [fish2.id]==uId(fidx(k));
        [fish(idx).id] = deal(k);
    end
end

toc;
progressbar(1);

if isempty(fish)
    warning('No fish found')
    return;
end

%% UNCOMMENT to plot all final fish frequency tracks in separate colors
% figure,clf, hold on;
% colormap('hot');
% caxis([0,1]);
% % col = distinguishable_colors(length(fish),[0,0,0]);
% 
% imagesc(T,F,normSmag(:,:,1));
% 
% % plot([fish.t],[fish.f1],'.m');
% for f = 1:length(fish)
%     idx = [fish.id]==f;
%     plot([fish(idx).t],[fish(idx).f1],'.','MarkerSize',20);%,'Color',col(f,:));
% end
% 
% xlim([T(1),T(end)]);
% ylim([minF1,maxF1]);
% set(gca, 'YDir', 'normal');
% hold off;

