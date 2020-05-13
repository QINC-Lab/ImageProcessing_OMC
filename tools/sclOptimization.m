function imScl = sclOptimization(a,x) % imScl = sclOptimization(a,interval,sh,pP)
    %load('bin.mat');
%     imScl = sum(a*interval'-pP(1+sh:1+sh+length(interval)-1));
    imScl = a*x';
end