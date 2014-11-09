clear
tols = [1e-1 8e-2 5e-2 2e-2 1e-2 8e-3 5e-3];



MLMCOPT = mlmcset;
MLMCOPT = mlmcset(MLMCOPT,'rmse',tols(1),'M1',16,'initN',20);

MLMC = mlmc(MLMCOPT);
MLMC.run
MLMC.summary

for i = 2 : length(tols)
    MLMC.set_tol(tols(i));
    MLMC.run
    MLMC.summary
end
