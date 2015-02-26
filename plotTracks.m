function [ret,h] = plotTracks(ax,tracks,selId)

if nargin<3
    selId = [];
end

ret = 0;
ids = unique([tracks.id]);
nTracks = length(ids);
col = distinguishable_colors(nTracks,{'r','k','y'});
h = zeros(nTracks,1);

for k = 1:nTracks
    idx = [tracks.id]==ids(k);
    idTrack = tracks(idx);
    
    [~,idx] = sort([idTrack.t]);
    idTrack = idTrack(idx);
    h(k) = plot(ax,[idTrack.t],[idTrack.f1],'.-','Color',col(k,:));
    
    if ismember(k,selId)
        plot(ax,[idTrack.t],[idTrack.f1],'oy');
    end
end

ret = sum(h);