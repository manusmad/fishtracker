% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('..');

baseFolder = uigetdir(pwd,'Select dataset folder ...');
trialFolder = 'terraronca';          

%% Choose which file to generate video for
particle_file_name      = 'TerraRonca_PostCalibration_05_100s_particle.mat';

tracked_dir_path        = fullfile(baseFolder,trialFolder,'tracked');
trackedVideo_dir_path   = fullfile(baseFolder,trialFolder,'tracked_video');
spec_dir_path           = fullfile(baseFolder,trialFolder,'spec');
freqtracks_dir_path     = fullfile(baseFolder,trialFolder,'freqtracks');
elec_dir_path           = fullfile(baseFolder,trialFolder,'elec');

spec_file_name          = strrep(particle_file_name,'particle','spec');
freqtracks_file_name    = strrep(particle_file_name,'particle','tracks');
elec_file_name          = strrep(particle_file_name,'particle','elec');

trackedVideo_file_name  = strrep(particle_file_name,'particle.mat','video');
trackedAudio_file_name  = strrep(particle_file_name,'particle.mat','audio');


%% Load files
    
load(fullfile(tracked_dir_path, particle_file_name));
spec                    = load(fullfile(spec_dir_path, spec_file_name),'spec');
freqtracks              = load(fullfile(freqtracks_dir_path, freqtracks_file_name),'tracks');
elec                    = load(fullfile(elec_dir_path, elec_file_name),'elec');

elec = elec.elec;
spec = hlp_deserialize(spec.spec);
tracks = freqtracks.tracks;
Smag = mean(normSpecMag(spec.S),3);

%% Video parameters

nFrame                  = length(particle.t);
frameInterval           = 767:962;
frameRate               = 8;
fishSelect              = [9 10];
nFrames                 = frameInterval(end)-frameInterval(1)+1;


%% Plot
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.01], [0.125 0.125], [0.03 0.01]);

fW                  = 1;
fL                  = 7;
colrs               = distinguishable_colors(length(fishSelect),{'r','k','y'});
scrsz               = get(groot,'ScreenSize');
hAxis               = figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)]);
set(gcf,'color',[1 1 1]);

writerObj           = VideoWriter(fullfile(trackedVideo_dir_path, trackedVideo_file_name),'MPEG-4');
writerObj.FrameRate = frameRate;

ids                 = unique([tracks.id]);
nTracks             = length(ids);

progressbar('Writing Video');
open(writerObj);  

flag                = zeros(1,particle.nFish);
dispStep            = ones(1,particle.nFish);
time1               = particle.t(frameInterval(1));
time2               = particle.t(frameInterval(end));

for frameIdx = frameInterval
    progressbar((frameIdx-frameInterval(1))/nFrames);

    time = particle.t(frameIdx);
    
    figure(hAxis), cla;
    
    h1 = subplot(1,2,1);
    hold on;

    plotSpectrogram(gca,spec.T,spec.F,Smag);
    
    for k = 1:length(fishSelect)
        idTrack = tracks([tracks.id]==ids(fishSelect(k)));
        [~,idx] = sort([idTrack.t]);
        idTrack = idTrack(idx);

        plot([idTrack.t],[idTrack.f1],'.-','Color',colrs(k,:),'LineWidth',3);
    end
    
    ylimits = [370,410];
    plot([time,time],ylimits,'--y','LineWidth',1);

    ylim(ylimits);
    xlim([time1,time2]);
    h1.FontSize = 12;
    xlim([spec.T(1),spec.T(end)]);

    xlabel('Time (s)','FontSize',12);
    ylabel('Frequency (Hz)','FontSize',12);
    title('Spectrogram with Frequency Tracks','FontSize',18);
    hold off;
    
    h2 = subplot(1,2,2);
    hold on;
    plot(particle.gridCoord(:,1),particle.gridCoord(:,2),'ok','LineWidth',3.01);
    plot(particle.gridCoord(:,1),particle.gridCoord(:,2),'+k','LineWidth',3.01);
    
    for i = 1:length(fishSelect)
        fID = fishSelect(i);
        if sum(~isnan(squeeze(particle.fish(fID).ampAct(:,frameIdx))))
            colrsMat = [colrs(i,:);colrs(i,:)];
            dispStep(fID) = frameIdx;
            flag(fID) = 0;
        else
            colrsMat = [1 1 1;colrs(i,:)];
            if flag(fID) == 0
                dispStep(fID) = frameIdx-1;
                flag(fID) = 1;
            end
        end
        pb=plot_ellipse(fW,fL,particle.fish(fID).x(dispStep(fID)),particle.fish(fID).y(dispStep(fID)),rad2deg(particle.fish(fID).theta(dispStep(fID))),[colrsMat(1,:); colrsMat(2,:)]);       
        alpha(pb,0.65);      
    end
    xlim([-125 125])
    ylim([-125 125])
    h2.FontSize = 12;
    set(gca,'YTick',[]);
    xlabel('Distance (cm)','FontSize',12);
    title('Overhead View with Spatial Estimates','FontSize',18);
    hold off;
    
    f = getframe(hAxis);
    writeVideo(writerObj,f);

end
close(writerObj);
progressbar(1);

%% Write audio

% Filter audio
f1 = 380;
f2 = 400;

Wp = 2*[f1 f2]/elec.meta.Fs;
Ws = 2*[0.9*f1 1.1*f2]/elec.meta.Fs;
Rp = 3;
Rs = 40;
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

y = filter(b,a,elec.data);
y = mean(y,2);
y = (y - min(y))/(max(y)-min(y));   % Normalize  0 - 1
y = y*2-1;                          % Normalize -1 - 1


idx = elec.t>=time1 & elec.t<=time2;
y = y(idx);

videoDuration = (frameInterval(end)-frameInterval(1)+1)/frameRate;

audioFs = round(elec.meta.Fs*(time2-time1)/videoDuration);
audiowrite(fullfile(trackedVideo_dir_path,[trackedAudio_file_name,'.wav']),y,audioFs);

display('Done')