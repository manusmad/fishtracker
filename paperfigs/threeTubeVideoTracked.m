load(fullfile('data','140417_034_videotracks'));

%%

clf, hold on;
imshow(tubeFrame);

% Show Tank markers
plot(tankcen(:,1),tankcen(:,2),'.b','MarkerSize',25);

% Show Grid markers
plot(gridcen(:,1),gridcen(:,2),'.g','MarkerSize',25);

% Show tracked Tube markers
plot(squeeze(fishCen(1,1,:)),squeeze(fishCen(1,2,:)),'.m','MarkerSize',20)
plot(squeeze(repmat(fishCen(1,1,:),2,1)) + [-20;20]*cos(squeeze(fishTheta(1,:))),...
    squeeze(repmat(fishCen(1,2,:),2,1)) + [20;-20]*sin(squeeze(fishTheta(1,:))),...
    'y')

leg = legend('Tank corner','Grid electrode','Tube center', 'Tube orientation');
leg.Color = 'none';
leg.Box = 'off';
leg.Location = 'northwest';

hold off;

print -dpdf threeTubeVideoTracked