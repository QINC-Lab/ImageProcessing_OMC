function y = genGauss(p,x)
    
    y = p(1) + p(2) .* exp(-(abs(x)/p(3)).^p(4));

end