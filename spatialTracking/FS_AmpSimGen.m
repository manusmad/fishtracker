function a = FS_AmpSimGen(X, gridcoord, depth)

xD = gridcoord(:,1);
yD = gridcoord(:,2);

N = length(xD);
P = size(X,2);

xF = X(1,:);
yF = X(2,:);
thF = X(3,:);

xF_end = xF + sin(thF);
yF_end = yF + cos(thF);

% figure()
% scatter(xD,yD)
% hold on
% plot(xF,yF);
% plot(xF_end,yF_end);

dipMid = [xF;yF;repmat(depth,1,P)]; % 3xP
dipEnd = [xF_end;yF_end;repmat(depth,1,P)]; % 3xP
gridPt = [xD'; yD'; repmat(0,1,N)];  %#ok<RPMT0> 
% 3xN

xElecDipMid = (repmat(xD,1,P)-repmat(xF,N,1));
yElecDipMid = (repmat(yD,1,P)-repmat(yF,N,1));
zElecDipMid = repmat(depth,N,P);

rMat = (xElecDipMid.^2 + yElecDipMid.^2 + zElecDipMid.^2).^0.5; %NxP

rVecMidEnd  = dipEnd - dipMid; % 3xP
for i = 1:N
    rVecMidElec = repmat(gridPt(:,i),1,P) -  dipMid; % 3xP
    cosThetaMat(i,:) = dot(rVecMidEnd,rVecMidElec)./(sqrt(sum(rVecMidEnd.^2,1)).*sqrt(sum(rVecMidElec.^2,1)));
end

% c = 0.6374;
c = 2;
r0cmodel = @(th0,r0) (th0) ./ r0.^c;  %0.77 
model = r0cmodel;

a = model(cosThetaMat,rMat);