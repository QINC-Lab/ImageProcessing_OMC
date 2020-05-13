function [res] = hx(ax,hx0,xsi,ki)
res=hx0*sqrt(ax.^(-xsi).*(ki.*ax+1-ki));

