function [res] = ajeta(x,d,eta)
res=1-d*(2*sl(x,eta).^3-3*sl(x,eta).^2+1);
end
