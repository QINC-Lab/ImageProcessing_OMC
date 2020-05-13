function [res] = sl(x,eta)
res=zeros(1,size(x,2));
for ii=1:size(x,2)
if x(ii) <= 0.5
    res(ii)=0.5*(2*x(ii))^eta;
else
    res(ii)= 1-0.5*(2*(1-x(ii)))^eta;
end
end


