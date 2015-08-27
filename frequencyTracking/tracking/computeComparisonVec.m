% Pre-compute comparison vector for candidates
function cand = computeComparisonVec(cand)
    for k = 1:length(cand)
        c = cand(k);
        cand(k).vec = [20*c.f1;2*mean(c.a1./c.a2);(c.a1-min(c.a1))/(max(c.a1)-min(c.a1))];
    end