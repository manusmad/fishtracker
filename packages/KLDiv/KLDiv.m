function dist=KLDiv(P,Q)
%  dist = KLDiv(P,Q) Kullback-Leibler divergence of two discrete probability
%  distributions
%  P and Q  are automatically normalised to have the sum of one on rows
% have the length of one at each 
% P =  n x nbins
% Q =  1 x nbins or n x nbins(one to one)
% dist = n x 1
%
% Modified-MSM-29-Jan-14
% Modified-RPJ-30-Jan-14

if size(P,2)~=size(Q,2)
    error('the number of columns in P and Q should be the same');
end

if sum(sum(~isfinite(P(:)))) + sum(sum(~isfinite(Q(:))))
   error('the inputs contain non-finite values!') 
end

% normalizing the P and Q
if size(Q,1)==1
    Q = (Q-min(Q))./(max(Q)-min(Q));
    Q = Q + 0.001;
    Q = Q ./sum(Q);

    
    P = (P - repmat(min(P,[],2),1,size(P,2))) ./ (repmat((max(P,[],2) - min(P,[],2)),1,size(P,2)));
    P = P + 0.001;
    P = P ./repmat(sum(P,2),[1 size(P,2)]);
    
    
    
    temp =  P.*log(P./repmat(Q,[size(P,1) 1]));
    temp(isnan(temp))=0;% resolving the case when P(i)==0
    dist = sum(temp,2);
    
    
elseif size(Q,1)==size(P,1)
    Q = (Q - repmat(min(Q,[],2),1,size(Q,2))) ./ (repmat((max(Q,[],2) - min(Q,[],2)),1,size(Q,2)));
    Q = Q + 0.001;
    Q = Q ./repmat(sum(Q,2),[1 size(Q,2)]);
    
%     P = (P - repmat(min(P,[],1),size(P,1),1)) ./ (repmat(max(P,[],1),size(P,1),1) - repmat(min(P,[],1),size(P,1),1));
    P = (P - repmat(min(P,[],2),1,size(P,2))) ./ (repmat((max(P,[],2) - min(P,[],2)),1,size(P,2)));
    P = P + 0.001;
    P = P ./repmat(sum(P,2),[1 size(P,2)]);
    
    temp =  P.*log(P./Q);
    temp(isnan(temp))=0; % resolving the case when P(i)==0
    dist = sum(temp,2);
end


