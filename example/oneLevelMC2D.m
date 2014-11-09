classdef oneLevelMC2D < montecarlo
    
    properties (SetAccess = private)
        CEM
        N
        bnd
        rhsf
        gD
        gN
        cx
        cy
        hx
        hy
        temp = zeros(10000,1);
        index = 1;
    end
    methods
        function OLMC = oneLevelMC2D(N)
            OLMC.N      = N;
            cemopt = cemoption;
            cemopt.set('norm','L1');
            cemopt.set('N', [N N 1]);
            cemopt.set('h', [1/N 1/N 0]);
            
            OLMC.CEM = cem(cemopt);
            OLMC.CEM.print
            % *** Set boundary condition
            % [N E W S] 1 : Dirichlet, 2 : Neumann
            OLMC.bnd = [2 1 1 2];
            OLMC.rhsf = 'zerofun';
            OLMC.gD = { 'zerofun' 'zerofun' 'onefun' 'zerofun'};     % Dirichlet boundary conditions
            OLMC.gN = {'zerofun' '' '' 'zerofun'};                   % Neuman boundary conditions
            
            xstart = 0; xend = 1;
            ystart = 0; yend = 1;
            [OLMC.cx, OLMC.cy, OLMC.hx, OLMC.hy]  = ...
                generate_regular2D(xstart,xend,ystart,yend,N,N);

        end
        function run(obj,n)
            for i = 1 : n
                k = exp(obj.CEM.generate_matrix);
                [A, b] = ccfv2D(obj.cx,obj.cy,obj.hx,obj.hy,obj.N,obj.N,k,obj.rhsf,obj.gD,obj.gN,obj.bnd);
                u = A\b;
%                 mesh(reshape(u,obj.N,obj.N))
%                 pause
                qoi = qoi_outflux(k,u,obj.N,obj.N);
                obj.temp(obj.index) = qoi;
                obj.index = obj.index + 1;
                obj.sumQ = obj.sumQ + qoi;
                obj.sumQ2 = obj.sumQ2 + qoi^2;               
            end
            
            obj.ns = obj.ns + n;
            
        end   
        

    end
end