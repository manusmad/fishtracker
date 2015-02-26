function d = naneuc(zi,Zj)

d = sqrt(nansum((repmat(zi,size(Zj,1),1)-Zj).^2,2));