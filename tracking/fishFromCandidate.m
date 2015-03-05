function cand = fishFromCandidate(cand,id,conf)

for k = 1:length(cand)
    cand(k).id = id(k);
    cand(k).conf = conf(k);
end