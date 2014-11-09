function qoi = qoi_outflux(k,p,Nx,Ny)
qoi = 0;

% fprintf(fid, '\n');
for j = 1 : Ny
    qoi = qoi + k(Nx,j)*p(j*Nx)*2;%*(hy/hx);    
end
