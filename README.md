MATMLMC
=======
What is MATMLMC
---------------
**MATMLMC** is a MATLAB toolbox for the multilevel Monte Carlo (MLMC) technique using the objected oriented programming.

Download 
--------
git clone git@github.com:parkmh/MATMLMC.git

Example Programs
----------------
Before running a example code, you need to install the following toolboxes.
* MATCEM <git clone git@github.com:parkmh/MATCEM.git>
* MATFVM <git clone git@github.com:parkmh/MATFVM.git>

Then run *mlmc2d.m* file in the *example* folder. This code quantify the outflow through the bouandy on the unit square domain using the multilevel Monte Carlo method. The groundwater flow is modelled using the Darcy's law and the incompressibility condition. The permeability is handle as a random so we use the stationary Gaussinan random field generation algorithm based the fast Fourier transform (FFT) called the circulant embedding method (CEM). 
