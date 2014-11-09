classdef twoLevelMC2D < montecarlo
    %TWOLEVELMC 이 클래스의 요약 설명 위치
    %   자세한 설명 위치
    
    properties (SetAccess = private)
        CEM
        N_f
        bnd
        rhsf
        gD
        gN
        cx_f
        cy_f
        hx_f
        hy_f
        
        N_c
        cx_c
        cy_c
        hx_c
        hy_c
        
        sumQ_f = 0;
        sumQ2_f = 0;
        sumQ_c = 0;
        sumQ2_c = 0;
        
    end
    
    methods
        function TLMC = twoLevelMC2D(N)
            TLMC.N_f = N;
            TLMC.N_c = N/2;
            
            cemopt = cemoption;
            cemopt.set('norm','L1');
            cemopt.set('N',[2*N+1 2*N+1 1]);
            cemopt.set('h',[1/(2*N) 1/(2*N) 0]);
            
            TLMC.CEM = cem(cemopt);
            TLMC.CEM.print
            % *** Set boundary condition
            % [N E W S] 1 : Dirichlet, 2 : Neumann
            TLMC.bnd = [2 1 1 2];
            TLMC.rhsf = 'zerofun';
            TLMC.gD = { 'zerofun' 'zerofun' 'onefun' 'zerofun'};     % Dirichlet boundary conditions
            TLMC.gN = {'zerofun' '' '' 'zerofun'};                   % Neuman boundary conditions
            
            xstart = 0; xend = 1;
            ystart = 0; yend = 1;
            
            [TLMC.cx_f, TLMC.cy_f, TLMC.hx_f, TLMC.hy_f]  = ...
                generate_regular2D(xstart,xend,ystart,yend,N,N);
            [TLMC.cx_c, TLMC.cy_c, TLMC.hx_c, TLMC.hy_c]  = ...
                generate_regular2D(xstart,xend,ystart,yend,N/2,N/2);
            
        end
        function run(obj,n)
            for i = 1 : n
                k = exp(obj.CEM.generate_matrix);
                k_f = k(2:2:end-1,2:2:end-1);
                k_c = k(3:4:end-1,3:4:end-1);
                
                [A_f, b_f] = ccfv2D(obj.cx_f,obj.cy_f,obj.hx_f,...
                    obj.hy_f,obj.N_f,obj.N_f,k_f,obj.rhsf,obj.gD,obj.gN,obj.bnd);
                [A_c, b_c] = ccfv2D(obj.cx_c,obj.cy_c,obj.hx_c,...
                    obj.hy_c,obj.N_c,obj.N_c,k_c,obj.rhsf,obj.gD,obj.gN,obj.bnd);
                u_f = A_f\b_f;
                u_c = A_c\b_c;
                

                qoi_f = qoi_outflux(k_f,u_f,obj.N_f,obj.N_f);
                qoi_c = qoi_outflux(k_c,u_c,obj.N_c,obj.N_c);

                obj.sumQ = obj.sumQ + (qoi_f-qoi_c);
                obj.sumQ2 = obj.sumQ2 + (qoi_f-qoi_c)^2;
                
                obj.sumQ_f = obj.sumQ_f + qoi_f;
                obj.sumQ2_f = obj.sumQ2_f + qoi_f^2;
                obj.sumQ_c = obj.sumQ_c + qoi_c;
                obj.sumQ2_c = obj.sumQ2_c + qoi_c^2;
            end
            obj.ns = obj.ns + n;
%             meanQf(obj)
        end
        function mVal = meanQf(obj)
            mVal = obj.sumQ_f/obj.ns;
        end
        function mVal = meanQc(obj)
            mVal = obj.sumQ_c/obj.ns;
        end
        
    end
    
end

