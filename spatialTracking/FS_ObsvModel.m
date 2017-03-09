function z = FS_ObsvModel(X, gridcoord, minElecIdx)

%% Description: 
% Observation model: Given the electrode grid coordinates and the location
% of a electric dipole source, this function calculates the theoretical
% electrode readings at each of the electrodes under the assumptions stated
% under Oscillating Dipole Model section in Online Methods of the paper. 

% Input variables:
%     X: (x,y,theta,z) position of dipole sources
%     gridcoord: (x,y,z) coordinates of electrodes. 
%     minElecIdx: Ref electrode to subtract off ground electrode as per
%     Eq(7)

% Output variables: 
%     z: Vector of electrode readings with respect to ref electrode
%     minElecIdx

% Author: Ravikrishnan Perur Jayakumar
%%

xD              = gridcoord(:,1);
yD              = gridcoord(:,2);
zD              = gridcoord(:,3);

N               = length(xD);
P               = size(X,2);
xF              = X(1,:);
yF              = X(2,:);
thF             = X(3,:);
zF              = X(4,:);
xF_end          = xF + cos(thF);
yF_end          = yF + sin(thF);
dipMid          = [xF;yF;zF]; % 3xP
dipEnd          = [xF_end;yF_end;zF]; % 3xP
gridPt          = [xD'; yD'; zeros(0,1,N)];  % 3xN
xElecDipMid     = (repmat(xD,1,P)-repmat(xF,N,1));
yElecDipMid     = (repmat(yD,1,P)-repmat(yF,N,1));
zElecDipMid     = repmat(zD,1,P)-repmat(zF,N,1);
rMat            = (xElecDipMid.^2 + yElecDipMid.^2 + zElecDipMid.^2).^0.5; %NxP
rVecMidEnd      = dipEnd - dipMid; % 3xP

for i = 1:N
    rVecMidElec = repmat(gridPt(:,i),1,P) -  dipMid; % 3xP
    cosThetaMat(i,:) = dot(rVecMidEnd,rVecMidElec)./(sqrt(sum(rVecMidEnd.^2,1)).*sqrt(sum(rVecMidElec.^2,1)));
end
c               = 2;
r0cmodel        = @(th0,r0) (th0) ./ r0.^c;
model           = r0cmodel;
a               = model(cosThetaMat,rMat);
[~,Midx]        = max(abs(a));
a               = a.*repmat(sign(a(sub2ind(size(a),Midx,1:size(a,2)))),size(a,1),1);
z               = a - repmat(a(minElecIdx,:), N, 1);

