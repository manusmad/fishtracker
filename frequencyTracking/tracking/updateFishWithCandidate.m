function fish = updateFishWithCandidate(fish,cand)

for k = 1:length(fish)
    cand(k).id = fish(k).id;
    cand(k).conf = fish(k).conf;
    fish(k) = cand(k);
end