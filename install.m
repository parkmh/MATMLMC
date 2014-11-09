% For more information, see <a href="matlab: 
% web('http://www.grandmaster.colorado.edu/~parkmh')">Minho Park's Web site</a>.
cd bin
Ver = mlmcversion;
user = 'Minho Park';
email = 'min.park@nottingham.ac.uk';
cd ..

clc
fprintf(' ********************************************\n')
fprintf('\n')
fprintf(' Matlab Multilevel Monte Carlo Toolbox  %s \n',Ver) 
fprintf('\n')
fprintf('%20s %s\n','Written by', user);
fprintf('%13s %s\n','email :',email);
fprintf(' ********************************************\n')


cwd = pwd;
matmlmcroot = pwd;

% Add path
% Generate amgpath.m file
fid = fopen([pwd filesep 'bin' filesep 'mlmcpath.m'],'w');
fprintf(fid,'function matmlmcpath = mlmcpath\n');

fprintf('\n1. Add path\n%s\n',matmlmcroot)

addpath(fullfile(matmlmcroot,'bin'));
fprintf(fid,'matmlmcpath = ''%s'';\n',matmlmcroot);

fclose(fid);
savepath



try
    
catch err
    cd ..
    error('mex -O compile error')
end
clear all

