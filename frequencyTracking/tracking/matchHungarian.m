function [R,C] = matchHungarian(fish,cand,assignThresh)

E = pdist2([fish.vec]',[cand.vec]',@naneuc);

% Assign fish to candidates using Hungarian algorithm
E(E>assignThresh) = Inf;
[M,~] = Hungarian(E);
[R,C] = find(M);