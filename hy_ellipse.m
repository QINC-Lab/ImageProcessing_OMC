function [res] = hy(ax,hy0,xsi,ki)
res=hy0*sqrt(ax.^xsi.*(ki.*ax+1-ki));
