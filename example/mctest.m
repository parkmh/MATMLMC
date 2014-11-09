% MC1 = oneLevelMC2D(8);
% MC2 = oneLevelMC2D(16);
% MC3 = oneLevelMC2D(32);
% MC4 = oneLevelMC2D(64);

MC1 = twoLevelMC2D(8);
MC2 = twoLevelMC2D(16);
MC3 = twoLevelMC2D(32);
MC4 = twoLevelMC2D(64);


%%
MC1.run(3000);
MC2.run(3000);
MC3.run(3000);
MC4.run(3000);

MC1.mean
MC2.mean
MC3.mean
MC4.mean

[MC1.meanQf MC1.meanQc]
[MC2.meanQf MC2.meanQc]
[MC3.meanQf MC3.meanQc]
[MC4.meanQf MC4.meanQc]

