function [ret,h] = plotTracks(ax,tracks,selId)

if nargin<3
    selId = [];
end

ret = 0;
ids = unique([tracks.id]);
%col = distinguishable_colors(nTracks,{'r','k','y'});
col = distinguishable_colors(max(ids),{'r','k','y'});
% nTracks = length(ids);
% h = zeros(nTracks,1);
idsAll = unique([tracks.id]);

% Select which tracks to plot
xLimits = xlim(ax);
yLimits = ylim(ax);

trackIdx = [tracks.t]>=xLimits(1) & [tracks.t]<xLimits(2) &...
    [tracks.f1]>yLimits(1) & [tracks.f1]<yLimits(2);
ids = unique([tracks(trackIdx).id]);
nTracks = length(ids);
h = zeros(nTracks,1);

for k = 1:nTracks
    idx = [tracks.id]==ids(k);
    idTrack = tracks(idx);
    
    [~,idx] = sort([idTrack.t]);
    idTrack = idTrack(idx);
    h(k) = plot(ax,[idTrack.t],[idTrack.f1],'.-','Color',col(ids(k),:));
    
    if ismember(ids(k),idsAll(selId))
        plot(ax,[idTrack.t],[idTrack.f1],'oy');
    end
end

ret = sum(h);