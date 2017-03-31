function cand = computeComparisonVec(cand)
% COMPUTECOMPARISONVEC Compute comparison vector for candidates
% 
% Comparison vector is just the concatenated amplitudes of the fundamental
% and second harmonic, but this can be changed.
%
% Manu S. Madhav
% 2016

    for k = 1:length(cand)
        c = cand(k);
        cand(k).vec = [c.a1;c.a2];
    end