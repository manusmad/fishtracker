function tracks = noRepeatTimes(tracks)
% NOREPEATTRACKS Delete duplicate track points
%
% If any track points have the same id and the same time, keep the track
% point with the highest max amplitude, and delete the rest.
%
% Manu S. Madhav
% 2016

A = [[tracks.id];[tracks.t]]'; % Combination of id and time should be unique.
[A,idx] = sortrows(A);
idxrepeats = find(~sum(abs(diff(A)),2));    % Find repeating id,time combos
[~,idxmax] = max([max([tracks(idx(idxrepeats)).a1]);max([tracks(idx(idxrepeats+1)).a1])]);  % Find the maximum peak among the repeating pairs

idxelim = [idx(idxrepeats(idxmax==2)) ; idx(idxrepeats(idxmax==1)+1)];  % Eliminate the other one
tracks(idxelim) = [];

