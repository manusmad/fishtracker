function fish = increaseConfidence(fish)

for k = 1:length(fish)
    fish(k).conf = fish(k).conf+1;
end