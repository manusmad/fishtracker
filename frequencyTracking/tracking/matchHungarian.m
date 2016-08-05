function [R,C] = matchHungarian(fish,cand,assignThresh)

E = pdist2([fish.vec]',[cand.vec]');
Ef = pdist2([fish.f1]',[cand.f1]');

% Assign fish to candidates using Hungarian algorithm
E(E>assignThresh) = Inf;
E(Ef>1) = Inf;

[M,~] = Hungarian(E);
[R,C] = find(M);