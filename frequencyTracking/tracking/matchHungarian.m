function [R,C] = matchHungarian(fish,cand,assignThresh)
% MATCHHUNGARIAN Uses the hungarian algorithm to match between lists of
% candidates.
% 
% Computes the pairwise euclidean distances between the comparison vectors 
% of 'fish' and 'cand', and for cases where the distance is below
% 'assignThresh', assigns cand to fish based on the Hungarian algorithm.
% Returns R and C, vectors of row and column of the assignment matrix.
%
% Manu S. Madhav
% 2016
% See also PDIST2, COMPUTECOMPARISONVEC, HUNGARIAN

E = pdist2([fish.vec]',[cand.vec]');
Ef = pdist2([fish.f1]',[cand.f1]');

% Assign fish to candidates using Hungarian algorithm
E(E>assignThresh) = Inf;
E(Ef>1) = Inf;

[M,~] = Hungarian(E);
[R,C] = find(M);