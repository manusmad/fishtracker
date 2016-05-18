function [powOpt,fopt] = FS_exponOptim(X,amp,gridXY)

options = optimoptions(@fmincon,'Algorithm','interior-point','MaxIter',10000,...
           'MaxFunEvals',10000,'TolFun',1e-12,'FinDiffType','central','TolX',1e-15, 'Display', 'off');
%        'DiffMaxChange',0.00000001,
%assuming the function is defined in the
%in the m file fun1.m we call fminunc
%with a starting point x0
% DiffMaxChange = 0.001;
% FinDiffRelStep = 
% FinDiffType = 'central';

pow0 = 1;

f               = @(pow) FS_exponObjFn(X,amp,gridXY,pow);
[powOpt,fopt]   = fmincon(f,pow0,[],[],[],[],0,3,[],options);
