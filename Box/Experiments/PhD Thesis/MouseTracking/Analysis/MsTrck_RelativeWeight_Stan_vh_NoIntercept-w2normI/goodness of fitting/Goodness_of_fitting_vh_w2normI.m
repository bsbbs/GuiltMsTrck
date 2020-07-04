dat = tdfread('/Users/boshen/Box/Experiments/PhD Thesis/MouseTracking/Analysis/MsTrck_RelativeWeight_Stan_vh_NoIntercept-w2normI/goodness of fitting/gof.dat.txt');
%% 

plot3(dat.time, dat.vh, dat.vh0x2Eest, '.')