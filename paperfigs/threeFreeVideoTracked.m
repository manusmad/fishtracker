load(fullfile('data','140422_001_04m00s_04m12s_videotracks'));

%% Extract clip (If video is available)
% v = VideoReader(fullfile('data','140422_001.mp4'));
% 
% nF = length(frameIdx);
% frames = cell(nF,1);
% for f = 1:nF
%     fr = read(v,frameIdx(f));
%     frames{f} = fr(ycrop(1):ycrop(2),xcrop(1):xcrop(2),:);
% end
% 
% save(fullfile('data','140422_001_04m00s_04m12s_frames'),'frames');

%%
load(fullfile('data','140422_001_04m00s_04m12s_frames'),'frames');

%%
f = 23;

clf, hold on;
imshow(frames{f});

% Show Tank markers
plot(tankcen(:,1),tankcen(:,2),'.b','MarkerSize',25);

% Show Grid markers
plot(gridcen(:,1),gridcen(:,2),'.g','MarkerSize',25);

% Show tracked fish markers
plot(squeeze(fishCen(f,1,:)),squeeze(fishCen(f,2,:)),'.m','MarkerSize',15)
plot(squeeze(repmat(fishCen(f,1,:),2,1)) + [-15;15]*cos(squeeze(fishTheta(f,:))),...
    squeeze(repmat(fishCen(f,2,:),2,1)) + [15;-15]*sin(squeeze(fishTheta(f,:))),...
    'y')

leg = legend('Tank corner','Grid electrode','Fish center', 'Fish orientation');
leg.Color = 'none';
leg.Box = 'off';
leg.Location = 'northwest';

hold off;

%%
print -dpdf threeFreeVideoTracked