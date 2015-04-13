function z = FS_ObsvModel(X, gridcoord, tankcoord, motion)
% Observation model
%
% X is the state vector, can be P-columns
% First three columns are x,y,theta of fish
%
% Manu Madhav, Ravikrishnan PJ
% 28-Jun-13

xD = gridcoord(:,1);
yD = gridcoord(:,2);

% tankDepth = (tankcoord(2,1)-tankcoord(1,1))/20;

N = length(xD);
        
xF = X(1,:);
yF = X(2,:);
thF = X(3,:);

if strcmp(motion,'randomLineCharge')
    L = X(4,:);
end

P = size(X,2);


% r = (repmat(xD,1,P)-repmat(xF, N,1)) + 1i*(repmat(yD,1,P)-repmat(yF, N,1));
% th = angle(r)-repmat(thF,N,1);
%     
% %      r = abs(r).^3;
% %     r = log(abs(r));
% %     r = abs(r).^2;
%  r = abs(r).^0.77;

% rvec = @(X0,Y0,Z0) (repma
% relang = @(rvec0,th0) 

rvec = @(X0,Y0) (repmat(xD,1,P)-repmat(X0, N,1)) + 1i*(repmat(yD,1,P)-repmat(Y0, N,1));
relang = @(rvec0,th0) angle(rvec0)-repmat(th0,N,1);

c = 0.77;
r07model = @(th0,r0) cos(th0) ./ abs(r0).^c;  %0.77
rmodel = @(th0,r0) cos(th0) ./ abs(r0);
r2model = @(th0,r0) cos(th0) ./ abs(r0).^2;
r3model = @(th0,r0) cos(th0) ./ abs(r0).^3;
logrmodel = @(th0,r0) cos(th0) ./ log(abs(r0));  
model = r07model;

dipMul = 1;

boundaryOn = 0;
boundaryVal = 0;
if boundaryOn
    % "First-reflection fishes" from tank
    % Left wall
    xF1 = 2*mean([tankcoord(1,1),tankcoord(4,1)]) - xF;
    yF1 = yF;
    thF1 = pi-thF;
    r1 = rvec(xF1,yF1);
    th1 = relang(r1,thF1);

    % Top wall
    xF2 = xF;
    yF2 = 2*mean([tankcoord(1,2),tankcoord(2,2)]) - yF;
    thF2 = -thF;
    r2 = rvec(xF2,yF2);
    th2 = relang(r2,thF2);

    % Right wall
    xF3 = 2*mean([tankcoord(2,1),tankcoord(3,1)]) - xF;
    yF3 = yF;
    thF3 = pi-thF;
    r3 = rvec(xF3,yF3);
    th3 = relang(r3,thF3);

    % Bottom wall
    xF4 = xF;
    yF4 = 2*mean([tankcoord(3,2),tankcoord(4,2)]) - yF;
    thF4 = -thF;
    r4 = rvec(xF4,yF4);
    th4 = relang(r4,thF4);
    
    %  Left - Top
    xF1F2  = xF1;
    yF1F2  = yF2;
    thF1F2 = pi + thF;
    r12    = rvec(xF1F2,yF1F2);
    th12   = relang(r12,thF1F2);
    
    %  Right - Top
    xF3F2  = xF3;
    yF3F2  = yF2;
    thF3F2 = pi + thF;
    r32    = rvec(xF3F2,yF3F2);
    th32   = relang(r32,thF3F2);
    
    %  Left - Bottom
    xF1F4  = xF1;
    yF1F4  = yF4;
    thF1F4 = pi + thF;
    r14    = rvec(xF1F4,yF1F4);
    th14   = relang(r14,thF1F4);
    
    %  Right - Bottom
    xF3F4  = xF3;
    yF3F4  = yF4;
    thF3F4 = pi + thF;
    r34    = rvec(xF3F4,yF3F4);
    th34   = relang(r34,thF3F4);

    boundaryVal = boundaryVal + dipMul*(model(th1,r1) + model(th2,r2) + model(th3,r3) + model(th4,r4)); ...
%                                    + model(th12,r12) + model(th32,r32) + model(th14,r14) + model(th34,r34));
end

r = rvec(xF,yF);
th = relang(r,thF);

if strcmp(motion, 'random') || strcmp(motion, 'uni')
%     a = cos(th)./(r) + FS_gen_obs_noise(N,P);         % Partial Model
    a = model(th,r) + boundaryVal;         % Partial Model
%     a = abs(a);
elseif strcmp(motion, 'randomLineCharge')
  x = r.*cos(th);  
  y = r.*sin(th);
  L = repmat(L,N,1);

  positiveLineV =  log(((x-L) - sqrt((x-L).^2 + (y).^2))./ ((x - sqrt(x.^2 + y.^2))));
  negativeLineV =  - log(((x+L) + sqrt((x+L).^2 + (y).^2))./ ((x + sqrt(x.^2 + y.^2))));
  
  totalLineV = positiveLineV + negativeLineV;
  
  a = totalLineV;
end
    
z = a - repmat(min(a), N, 1);
