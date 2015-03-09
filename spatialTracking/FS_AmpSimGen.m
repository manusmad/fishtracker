function a = FS_AmpSimGen(X,motion,gridCoord,c)
% Observation mode

xD = gridCoord(:,1);
yD = gridCoord(:,2);
N = length(xD);

xF = X(1,:);
yF = X(2,:);
thF = X(3,:);

if strcmp(motion,'randomLineCharge')
    L = X(4,:);
end
L = 2;

P = size(X,2);

r  = (repmat(xD,1,P)-repmat(xF, N,1)) + 1i*(repmat(yD,1,P)-repmat(yF, N,1));
th = angle(r)-repmat(thF,N,1);
    
%      r = abs(r).^3;
%     r = log(abs(r));
% r = abs(r).^2;
% c = 0;
 r = (abs(r) + c).^.77;
% 
if strcmp(motion, 'random') || strcmp(motion, 'uni')
    a = cos(th)./(r);         % Partial Model
elseif strcmp(motion, 'randomLineCharge')
  x = r.*cos(th);  
  y = r.*sin(th);
  L = repmat(L,N,1);

  positiveLineV =  log(((x-L) - sqrt((x-L).^2 + (y-L).^2))./ ((x - sqrt(x.^2 + y.^2))));
  negativeLineV =  - log(((x+L) + sqrt((x+L).^2 + (y-L).^2))./ ((x + sqrt(x.^2 + y.^2))));
  
  totalLineV = positiveLineV + negativeLineV;
  
  a = totalLineV;
end
% %     
%     N1 = min(size(a));              %%----
%     aMin = min(a,[],1);
%     z = a - repmat(aMin, N1, 1);

%     a(:,1)
%  sum(sum(~isfinite(a)))
% a = a(2:end) - a(1) + gen_obs_noise(N-1,P);

        


