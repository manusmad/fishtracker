% Pre-compute comparison vector for candidates
function cand = computeComparisonVec(cand)
    for k = 1:length(cand)
        c = cand(k);
%         cand(k).vec = [500*c.f1;2*mean(c.a1./c.a2);(c.a1-min(c.a1))/(max(c.a1)-min(c.a1))];
%         cand(k).vec = [30*c.f1;c.a1;c.a2];
        cand(k).vec = [c.a1;c.a2];
    end