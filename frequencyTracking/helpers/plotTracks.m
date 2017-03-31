function [ret,h] = plotTracks(ax,tracks,selId)
% PLOTTRACKS Plots track lines on spectrogram
%
% Plots track points in the 'track' structure axis 'ax'. Each track is 
% plotted in a separate color. The selected tracks in 'selId' are
% highlighted.
% Returns ret=1 if successful, else ret = 0. 'h' is the returned handle to
% the plot.
%
% Manu S. Madhav
% 2016

if nargin<3
    selId = [];
end

ret = 0;
ids = unique([tracks.id]);
col = distinguishable_colors(max(ids),{'r','k','y'});
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