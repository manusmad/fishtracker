function [x,y]=MagnetGInput2(h,MARK)
% MAGNETGINPUT(h,N,test)
% Given the handle of the plot, h, MAGNETGINPUT will either
% return the position clicked (upon right button press) or
% the location of the datapoint closest to the position
% clicked (upon left button press)
%
% If N is provided, MagnetGInput will allow N button clicks
%
% The closest datapoint is determined by minimizing the
% distance which is weighted by the scale of the figure,
% such that if your figure is [0:1:0:1000], the distance
% is
%
%    sqrt(((X-x)./1).^2+((Y-y)./1000).^2);
%
% It returns the abscissa and ordinate of the point clicked
% or datapoint closest to that point as well as the distance
% from the returned position to the click.
%
% If TEST is set true, MAGENETGINPUT will draw a red line
% from the click to the closest datapoint and a red circle
% using the click as the origin and the distance to the
% closest datapoint as a radius
%
% USAGE:
%
%   y=sin([.1:.1:10])+rand(1,100).*0.1;
%   h=plot([1:100],y,'-');
%   [xin,yin,rin]=MagnetGInput(h);
%   % click on your plot with the LEFT mouse button
%   line(xin+[0 10],yin+[0 .5],'color','r');
%   text(xin+10,yin+.5,{'This datapoint','was the closest to','your mouse click'},'color','r');
%   hold on;plot(xin,yin,'ro');
%   
% IT'S NOT FANCY BUT IT WORKS.

% Michael Robbins
% robbins@bloomberg.net
% michael.robbins@us.cibc.com
%
% Modified by Manu Madhav
% 01-Jul-14

if nargin<2 N=1; end;
if nargin<3 MARK=0; end;

ax = get(h(1),'Parent');
axes(ax);
X=get(h,'XData');
Y=get(h,'YData');

if iscell(X)
    X = [X{:}];
    Y = [Y{:}];
end
    
XScale=diff(get(gca,'XLim'));
YScale=diff(get(gca,'YLim'));

try
%     [xclick,yclick,button]=ginputc(1,'LineWidth',1,'Color','w');
    [xclick,yclick,button]=ginputax(ax,1);
% [xclick,yclick] = getpts(ax);
    if button==1
        if length(X) == length(Y)       % 1-D data
            r=sqrt(((X-xclick)./XScale).^2+((Y-yclick)./YScale).^2);
            [~,i]=min(r);
            x=X(i);
            y=Y(i);
        else
            [~,i] = min(abs(X-xclick));
            [~,j] = min(abs(Y-yclick));
            x = X(i);
            y = Y(j);
        end
    else
        [x,y] = deal([]);
        setptr(gcf,'arrow');
    end
catch
    [x,y] = deal([]);
    setptr(gcf,'arrow');
end

if MARK
    hold on;
    plot(x,y,'oc','MarkerSize',10);
    hold off;
end