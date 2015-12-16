function f = FS_exponObjFn(X,amp, gridXY, pow)

xD  = gridXY(:,1);
yD  = gridXY(:,2);
N   = size(gridXY,1);
        
xF  = X(:,1);
yF  = X(:,2);
thF = X(:,3);

P   = size(X,1);

r   = (repmat(xD,1,P)-repmat(xF', N,1)) + 1i*(repmat(yD,1,P)-repmat(yF', N,1));
th  = angle(r)-repmat(thF',N,1);
    
r = abs(r).^pow;

a = cos(th)./(r);        
[~,Midx] = max(abs(a));
a = a.*repmat(sign(a(sub2ind(size(a),Midx,1:size(a,2)))),size(a,1),1);
%%

[~,actMinIdx] = min(amp);
vecIdx = sub2ind(size(amp), actMinIdx, 1:P);
zAct = amp - repmat(min(amp), N, 1);
idx = find(~isnan(zAct));
zAct = zAct(idx);
zActScaled = zAct/max(abs(zAct));
% zEst = a - repmat(a(vecIdx), N, 1);
zEst = a - repmat(min(a), N, 1);
zEst = zEst(idx);
zEstScaled = zEst/max(abs(zEst));

f = norm(zActScaled - zEstScaled);


