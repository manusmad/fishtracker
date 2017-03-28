function handles = interpolateTracks(handles)
% INTERPOLATETRACKS Interpolate points between tracks
%
% Function to 'interpolate' tracks, i.e. add points to all the tracks if
% the gap between two adjacent track points is within a certain time
% threshold.
%
% Manu S. Madhav
% 2016
% See also ADDLINE

    ids = unique([handles.tracks.id]);
    
    dT = diff(handles.spec.T(1:2));
    
    for id = ids
        track = handles.tracks([handles.tracks.id]==id);
        track = track(~isnan([track.f1]));
        
        tDiff = diff([track.t]);
        tDiffIdx = find(tDiff>dT & tDiff<=5);
        
        for k = 1:length(tDiffIdx)
            time1 = track(tDiffIdx(k)).t;
            time2 = track(tDiffIdx(k)+1).t;
            
            freq1 = track(tDiffIdx(k)).f1;
            freq2 = track(tDiffIdx(k)+1).f1;
            
            handles = addLine(handles,id,time1,freq1,time2,freq2);
        end
    end
