% Add all Mathworks folders
addpath(fullfile('..','packages','addpath_recurse'));
addpath_recurse(fullfile('..'));

baseFolder = uigetdir(pwd,'Select dataset folder ...');

trialFolders = {'data_lab_2014_04_03_singleTubeTrials','data_lab_2014_04_17_threeTubeTrials'};

V_all = [];
E_all = [];
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
            V(n).x = mean((vidTracked.fishCen(:,1,n)-vidTracked.gridcen(5,1))/6);
            V(n).y = mean((vidTracked.fishCen(:,2,n)-vidTracked.gridcen(5,2))/6);
            V(n).theta = circ_mean(vidTracked.fishTheta(:,n));
            
            E(n).x = mean(particle.fish(n).x(timeIdx));
            E(n).y = mean(particle.fish(n).y(timeIdx));
            E(n).theta = circ_mean(particle.fish(n).theta(timeIdx)); 
        end
        
        V_all = [V_all,V(fishMap(j,:))];
        E_all = [E_all,E];
    end
end

vidTrack = struct('x',num2cell(vertcat(V_all.x)),...
    'y',num2cell(vertcat(V_all.y)),...
    'theta',num2cell(vertcat(V_all.theta)));

elecTrack = struct('x',num2cell(vertcat(E_all.x)),...
    'y',num2cell(vertcat(E_all.y)),...
    'theta',num2cell(vertcat(E_all.theta)));

gridCoord = (vidTracked.gridcen - repmat(vidTracked.gridcen(5,:),9,1))/6;
gridCoord = [gridCoord(:,1) -gridCoord(:,2)];   % Inverting Y-axis
gridLim = [min(gridCoord(:,1)),max(gridCoord(:,1)),min(gridCoord(:,2)),max(gridCoord(:,2))];

withinGridIdx = [vidTrack.x]>=gridLim(1) &...
    [vidTrack.x]<=gridLim(2) &...
    [vidTrack.y]>=gridLim(3) &...
    [vidTrack.y]<=gridLim(4);
    
vidTrack_in = vidTrack(withinGridIdx);
elecTrack_in = elecTrack(withinGridIdx);
vidTrack_out = vidTrack(~withinGridIdx);
elecTrack_out = elecTrack(~withinGridIdx);

N_all = length(vidTrack);
N_in = sum(withinGridIdx);
N_out = sum(~withinGridIdx);


%% Compute errors

% Functions to compute errors
errXY = @(e,v) sqrt( ([e.x]-[v.x]).^2 + ([e.y]-[v.y]).^2 );
angdiff = @(a,b) angle(exp(1i*a)./exp(1i*b));
errTheta = @(e,v) rad2deg( abs (angdiff(2*[e.theta],wrapToPi([v.theta]*2))/2) );
% Functions to compute RMS errors
rmsXY = @(e,v) sqrt(mean( ([e.x]-[v.x]).^2 + ([e.y]-[v.y]).^2 ));
rmsTheta = @(e,v) rad2deg(sqrt(mean ( (angdiff(2*[e.theta],wrapToPi([v.theta]*2))/2).^2 )));

e_xy_data_all = errXY(elecTrack,vidTrack);
e_xy_data_in = errXY(elecTrack_in,vidTrack_in);
e_xy_data_out = errXY(elecTrack_out,vidTrack_out);

e_theta_data_all = errTheta(elecTrack,vidTrack);
e_theta_data_in = errTheta(elecTrack_in,vidTrack_in);
e_theta_data_out = errTheta(elecTrack_out,vidTrack_out);

%% Compute Empirical cumulative distributions of data

d_xy = 0.1;
d_theta = 0.1;

edges_xy = 0:d_xy:100;
edges_theta = 0:d_theta:90;

nbins_xy = length(edges_xy)-1;
nbins_theta = length(edges_theta)-1;

centers_xy = edges_xy(1:nbins_xy) + d_xy/2;
centers_theta = edges_theta(1:nbins_theta) + d_theta/2;

% Functions to compute histogram
histXY = @(e,v) histcounts(errXY(e,v),edges_xy);
histTheta = @(e,v) histcounts(errTheta(e,v),edges_theta);
% Functions to compute empirical cumulative distribution
cumXY = @(e,v) cumsum(histXY(e,v))/sum(histXY(e,v))*100;
cumTheta = @(e,v) cumsum(histTheta(e,v))/sum(histTheta(e,v))*100;

cum_xy_data_all = cumXY(elecTrack,vidTrack);
cum_xy_data_in = cumXY(elecTrack_in,vidTrack_in);
cum_xy_data_out = cumXY(elecTrack_out,vidTrack_out);

cum_theta_data_all = cumTheta(elecTrack,vidTrack);
cum_theta_data_in = cumTheta(elecTrack_in,vidTrack_in);
cum_theta_data_out = cumTheta(elecTrack_out,vidTrack_out);

%% Compute RMS errors and empirical cumulative distributions of shuffled data

% To generate same plots as in paper. Comment to generate new pseudorandom shuffling 
rng(0,'twister');

cycles = 100000;

[cum_xy_shuffled_all,cum_xy_shuffled_in,cum_xy_shuffled_out] = deal(zeros(cycles,nbins_xy));
[cum_theta_shuffled_all,cum_theta_shuffled_in,cum_theta_shuffled_out] = deal(zeros(cycles,nbins_theta));
[rms_xy_shuffled_in,rms_theta_shuffled_in,...
    rms_xy_shuffled_out,rms_theta_shuffled_out,...
    rms_xy_shuffled_all,rms_theta_shuffled_all] = deal(zeros(cycles,1));

progressbar('Iterating');
for n = 1:cycles
    progressbar(n/cycles);

    perm = randperm(N_all);
    cum_xy_shuffled_all(n,:) = cumXY(elecTrack,vidTrack(perm));
    cum_theta_shuffled_all(n,:) = cumTheta(elecTrack,vidTrack(perm));
    rms_xy_shuffled_all(n) = rmsXY(elecTrack,vidTrack(perm));
    rms_theta_shuffled_all(n) = rmsTheta(elecTrack,vidTrack(perm));

    perm = randperm(N_in);
    cum_xy_shuffled_in(n,:) = cumXY(elecTrack_in,vidTrack_in(perm));
    cum_theta_shuffled_in(n,:) = cumTheta(elecTrack_in,vidTrack_in(perm));
    rms_xy_shuffled_in(n) = rmsXY(elecTrack_in,vidTrack_in(perm));
    rms_theta_shuffled_in(n) = rmsTheta(elecTrack_in,vidTrack_in(perm));
    
    perm = randperm(N_out);
    cum_xy_shuffled_out(n,:) = cumXY(elecTrack_out,vidTrack_out(perm));
    cum_theta_shuffled_out(n,:) = cumTheta(elecTrack_out,vidTrack_out(perm));
    rms_xy_shuffled_out(n) = rmsXY(elecTrack_out,vidTrack_out(perm));
    rms_theta_shuffled_out(n) = rmsTheta(elecTrack_out,vidTrack_out(perm));
end
progressbar(1);

rms_xy_data_all = rmsXY(elecTrack,vidTrack);
rms_theta_data_all = rmsTheta(elecTrack,vidTrack);

rms_xy_data_in = rmsXY(elecTrack_in,vidTrack_in);
rms_theta_data_in = rmsTheta(elecTrack_in,vidTrack_in);

rms_xy_data_out = rmsXY(elecTrack_out,vidTrack_out);
rms_theta_data_out = rmsTheta(elecTrack_out,vidTrack_out);

%% Plot 1, Cumulative errors

col = distinguishable_colors(3,'w');

scrsz = get(groot,'ScreenSize');
figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)]), clf;

subplot(2,1,1), hold on;
    % Compute quantiles
    q_all_lower = quantile(cum_xy_shuffled_all,0.001);
    q_in_lower = quantile(cum_xy_shuffled_in,0.001);
    q_out_lower = quantile(cum_xy_shuffled_out,0.001);
    
    q_all_upper = quantile(cum_xy_shuffled_all,0.999);
    q_in_upper = quantile(cum_xy_shuffled_in,0.999);
    q_out_upper = quantile(cum_xy_shuffled_out,0.999);
    
    patch([centers_xy,fliplr(centers_xy)],[q_all_lower,fliplr(q_all_upper)],col(1,:),'FaceAlpha',0.3,'EdgeColor',col(1,:));
    plot(centers_xy,mean(cum_xy_shuffled_all),'Color',col(1,:));

    patch([centers_xy,fliplr(centers_xy)],[q_in_lower,fliplr(q_in_upper)],col(2,:),'FaceAlpha',0.3,'EdgeColor',col(2,:));
    plot(centers_xy,mean(cum_xy_shuffled_in),'Color',col(2,:));
    
    patch([centers_xy,fliplr(centers_xy)],[q_out_lower,fliplr(q_out_upper)],col(3,:),'FaceAlpha',0.3,'EdgeColor',col(3,:));
    plot(centers_xy,mean(cum_xy_shuffled_out),'Color',col(3,:));

    h1 = plot(centers_xy,cum_xy_data_all,'Color',col(1,:),'LineWidth',1);
    h2 = plot(centers_xy,cum_xy_data_in,'Color',col(2,:),'LineWidth',1);
    h3 = plot(centers_xy,cum_xy_data_out,'Color',col(3,:),'LineWidth',1);
    
    legend([h1,h2,h3],'All','Inside grid','Outside grid','Location','SouthEast');
    
    xlabel('Position Estimate Error (cm)','FontSize',15); ylabel('Cumulative percentage of pose estimates','FontSize',15);
    plot([20 20],get(gca,'ylim'),'color','k','LineWIdth',2);
    title({'Position Error'},'FontSize',18);
    
    ylim([0 100])
    xlim([0 100])
    set(gca,'FontSize',15)
hold off;

subplot(2,1,2), hold on;
    % Compute quantiles
    q_all_lower = quantile(cum_theta_shuffled_all,0.001);
    q_in_lower = quantile(cum_theta_shuffled_in,0.001);
    q_out_lower = quantile(cum_theta_shuffled_out,0.001);
    
    q_all_upper = quantile(cum_theta_shuffled_all,0.999);
    q_in_upper = quantile(cum_theta_shuffled_in,0.999);
    q_out_upper = quantile(cum_theta_shuffled_out,0.999);

    patch([centers_theta,fliplr(centers_theta)],[q_all_lower,fliplr(q_all_upper)],col(1,:),'FaceAlpha',0.3,'EdgeColor',col(1,:));
    plot(centers_theta,mean(cum_theta_shuffled_all),'Color',col(1,:));

    patch([centers_theta,fliplr(centers_theta)],[q_in_lower,fliplr(q_in_upper)],col(2,:),'FaceAlpha',0.3,'EdgeColor',col(2,:));
    plot(centers_theta,mean(cum_theta_shuffled_in),'Color',col(2,:));
    
    patch([centers_theta,fliplr(centers_theta)],[q_out_lower,fliplr(q_out_upper)],col(3,:),'FaceAlpha',0.3,'EdgeColor',col(3,:));
    plot(centers_theta,mean(cum_theta_shuffled_out),'Color',col(3,:));
        
    plot(centers_theta,cum_theta_data_all,'Color',col(1,:),'LineWidth',1);
    plot(centers_theta,cum_theta_data_in,'Color',col(2,:),'LineWidth',1);
    plot(centers_theta,cum_theta_data_out,'Color',col(3,:),'LineWidth',1);
    
    xlabel('Angle Estimate Error (deg)','FontSize',15); ylabel('Cumulative percentage of pose estimates','FontSize',15);
    title('Orientation Error','FontSize',18);
    
    ylim([0 100])
    xlim([0 90])
    set(gca,'FontSize',15)
hold off;
export_fig('cumulative_error_tube.pdf','-pdf','-nocrop','-painters')

%% Plot 2, Shuffled rms error distributions

figure('Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/2 scrsz(4)]), clf;

subplot(2,1,1),hold on;
    title('Shuffled, Position','FontSize',18)
    xlabel('RMS error (cm)');
    ylabel('Counts');
    xlim([10,80]);

    histogram(rms_xy_shuffled_all,edges_xy,'EdgeAlpha',0,'FaceColor',col(1,:),'Normalization','probability');
    histogram(rms_xy_shuffled_in,edges_xy,'EdgeAlpha',0,'FaceColor',col(2,:),'Normalization','probability');
    histogram(rms_xy_shuffled_out,edges_xy,'EdgeAlpha',0,'FaceColor',col(3,:),'Normalization','probability');
    
    legend('All data','Inside grid','Outside grid');

    q_all = quantile(rms_xy_shuffled_all,0.001);
    q_in = quantile(rms_xy_shuffled_in,0.001);
    q_out = quantile(rms_xy_shuffled_out,0.001);
    
    plot([q_all,q_all],ylim,'--','Color',col(1,:));
    plot([q_in,q_in],ylim,'--','Color',col(2,:));
    plot([q_out,q_out],ylim,'--','Color',col(3,:));
    
    plot(rms_xy_data_all,0,'.','MarkerSize',30,'Color',col(1,:));
    plot(rms_xy_data_in,0,'.','MarkerSize',30,'Color',col(2,:));
    plot(rms_xy_data_out,0,'.','MarkerSize',30,'Color',col(3,:));
    
    set(gca,'FontSize',15);
hold off;

subplot(2,1,2), hold on;
    title('Shuffled, Angle','FontSize',18)
    xlabel('RMS error (deg)');
    ylabel('Counts')
    xlim([25,65]);
    
    histogram(rms_theta_shuffled_all,edges_theta,'EdgeAlpha',0,'FaceColor',col(1,:),'Normalization','probability');
    histogram(rms_theta_shuffled_in,edges_theta,'EdgeAlpha',0,'FaceColor',col(2,:),'Normalization','probability');
    histogram(rms_theta_shuffled_out,edges_theta,'EdgeAlpha',0,'FaceColor',col(3,:),'Normalization','probability'); 
  
    q_all = quantile(rms_theta_shuffled_all,0.001);
    q_in = quantile(rms_theta_shuffled_in,0.001);
    q_out = quantile(rms_theta_shuffled_out,0.001);
    
    plot([q_all,q_all],ylim,'--','Color',col(1,:));
    plot([q_in,q_in],ylim,'--','Color',col(2,:));
    plot([q_out,q_out],ylim,'--','Color',col(3,:));
    
    plot(rms_theta_data_all,0,'.','MarkerSize',30,'Color',col(1,:));
    plot(rms_theta_data_in,0,'.','MarkerSize',30,'Color',col(2,:));
    plot(rms_theta_data_out,0,'.','MarkerSize',30,'Color',col(3,:));
    
    set(gca,'FontSize',15)
hold off;

export_fig('shuffled_rms_error_tube.pdf','-pdf','-nocrop','-painters')
