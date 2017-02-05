% Creates shuffled data distributions from tube data for error plots, 
% and saves the data.
%
% Manu S. Madhav
% 05-Feb-2017

% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('..');

% baseFolder = uigetdir(pwd,'Select dataset folder ...');
baseFolder = '/Volumes/RaviHDD/grid_data';

trialFolders = {'140403_singleTubeTrials','140417_threeTubeTrials'};

vidTrack = [];
elecTrack = [];
for k = 1:length(trialFolders)
    trialFolder = trialFolders{k};
    fprintf('\nTrial Folder: %s\n',trialFolder);
    
    videotracks_dir_path    = fullfile(baseFolder,trialFolder,'videotracks');
    tracked_dir_path        = fullfile(baseFolder,trialFolder,'tracked');
    
    particleFileNames = dir(fullfile(tracked_dir_path,'*_particle.mat'));
    particleFileNames = {particleFileNames.name};
    
    try
        load(fullfile(baseFolder,trialFolder,'fishMap'))
    catch
        fishMap = ones(length(particleFileNames),1);
    end
    
    for j = 1:length(particleFileNames)
        particle_file_name = particleFileNames{j};
        videotracks_file_name   = strrep(particle_file_name,'particle','videotracks');
        
        % Load files 
        load(fullfile(tracked_dir_path, particle_file_name));
        vidTracked              = load(fullfile(videotracks_dir_path, videotracks_file_name));  
        
        nSteps                  = length(vidTracked.frameTime);
        elecTime                = particle.t;
        timeIdx                 = zeros(nSteps,1);
        
        for n = 1:nSteps
           [~,timeIdx(n)] = min(abs(elecTime - vidTracked.frameTime(n)));
        end
        
        for n = 1:vidTracked.nFish
            V(n).x = (mean(vidTracked.fishCen(:,1,n))-vidTracked.gridcen(5,1))/6;
            V(n).y = (mean(vidTracked.fishCen(:,2,n))-vidTracked.gridcen(5,2))/6;
            V(n).theta = circ_mean(vidTracked.fishTheta(:,n));
            
            E(n).x = mean(particle.fish(n).x(unique(timeIdx)));
            E(n).y = mean(particle.fish(n).y(unique(timeIdx)));
            E(n).theta = circ_mean(particle.fish(n).theta(unique(timeIdx))); 
        end
        
        vidTrack = [vidTrack,V(fishMap(j,:))];
        elecTrack = [elecTrack,E];
    end
end

%% Random permutations

cycles = 1000;

[V,E] = deal([]);
for n = 1:cycles
   E = [E,elecTrack];
   V = [V,vidTrack(randperm(length(vidTrack)))];
end

E = E';
V = V';

%%

distError = sqrt( ([E.x]-[V.x]).^2 + ([E.y]-[V.y]).^2 );

thetaError = circ_dist([E.theta],[V.theta]);
flipPosIdx = find(thetaError > pi/2);
thetaError(flipPosIdx) = thetaError(flipPosIdx) -pi;
flipNegIdx = find(thetaError < -pi/2);
thetaError(flipNegIdx) = thetaError(flipNegIdx) +pi;
thetaError = abs(thetaError);

save(fullfile(baseFolder,'shuffledTubeData.mat'),'distError','thetaError','E','V');

%%
% subplot(2,1,1);
% centers = linspace(0,70,10000);
% [counts,centers] = hist(distError,centers);
% plot(centers,cumsum(counts/sum(counts))*100,'LineWidth',1);
% 
% subplot(2,1,2);
% [counts,centers] = hist(thetaError,2000);
% plot(centers,cumsum(counts/sum(counts))*100,'LineWidth',1);
