function [R,C] = matchHungarian(fish,cand,assignThresh)

E = pdist2([10000*[fish.f1]' [fish.a1]'],[10000*[cand.f1]' [cand.a1]'],@naneuc);

% Assign fish to candidates using Hungarian algorithm
E(E>assignThresh) = Inf;
[M,~] = Hungarian(E);
[R,C] = find(M);