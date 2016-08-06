function z = FS_ObsvModel(X, gridcoord, tankcoord, motion,fittedExpModel,minElecIdx)
% Observation model

xD = gridcoord(:,1);
yD = gridcoord(:,2);

N = length(xD);
P = size(X,2);

xF = X(1,:);
yF = X(2,:);
thF = X(3,:);
if strcmp(motion,'random3D')
    zF = X(4,:);
else
    zF = repmat(0,1,P);
end


xF_end = xF + cos(thF);
yF_end = yF + sin(thF);

dipMid = [xF;yF;zF]; % 3xP
dipEnd = [xF_end;yF_end;zF]; % 3xP
gridPt = [xD'; yD'; repmat(0,1,N)];  %#ok<RPMT0> 
% 3xN

xElecDipMid = (repmat(xD,1,P)-repmat(xF,N,1));
yElecDipMid = (repmat(yD,1,P)-repmat(yF,N,1));
zElecDipMid = -repmat(zF,N,1);

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

[~,Midx] = max(abs(a));
a = a.*repmat(sign(a(sub2ind(size(a),Midx,1:size(a,2)))),size(a,1),1);

%{
% Make maximum amplitude positive
[~,Midx] = max(abs(a));
% MidxElemList = Midx + (0:size(a,2)-1)*16;
a = a.*repmat(sign(a(sub2ind(size(a),Midx,1:size(a,2)))),size(a,1),1);
z = a - repmat(min(a), N, 1);
%}
z = a - repmat(a(minElecIdx,:), N, 1);

