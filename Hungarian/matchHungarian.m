function [R,C] = matchHungarian(fish,cand,assignThresh)

E = pdist2([10*[fish.f1]' normSpecMag([fish.a1])' mean([fish.a1]./[fish.a2])'],[10*[cand.f1]' normSpecMag([cand.a1])' mean([cand.a1]./[cand.a2])'],@naneuc);

% Assign fish to candidates using Hungarian algorithm
E(E>assignThresh) = Inf;
[M,~] = Hungarian(E);
[R,C] = find(M);