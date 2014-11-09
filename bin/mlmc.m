classdef mlmc < handle
    %MLMC Multilevel Monte Carlo class
    %   자세한 설명 위치
    
    properties (SetAccess = private)
        opt
        mlmc_obj
        Ml = 0;
        level = 1;
        optimal_nsamp
        time
        tol
        second_run = false;
        s
    end
    
    methods
        % Constructor
        function MLMC = mlmc(opt)
            MLMC.opt    = opt;
            MLMC.mlmc_obj = cell(mlmcget(opt,'maxL',7),1);
            MLMC.optimal_nsamp = zeros(mlmcget(opt,'maxL',7),1);
            MLMC.time = zeros(mlmcget(opt,'maxL',7),1);
            MLMC.tol = mlmcget(opt,'rmse',1e-2);
            MLMC.second_run = false;
            MLMC.s = 2^mlmcget(opt,'dim',2);
        end
        
        function run(obj)
            if ~obj.second_run
                initRun(obj);
                obj.second_run = true;
            end
            
            while (serr(obj) > obj.tol^2/2)
                update_optimal_nsamp(obj)
                update(obj)
            end
            
            while ~checkBiasError(obj)
                if obj.level == mlmcget(obj.opt,'maxL',7)
                    break;
                end
                addLevel(obj,mlmcget(obj.opt,'initN',10));
                update_optimal_nsamp(obj)
                update(obj)
                while (serr(obj) > obj.tol^2/2)
                    update_optimal_nsamp(obj)
                    update(obj)
                end
            end
            
        end
        
        function set_tol(obj,tol)
            if tol >= obj.tol
                error('Input tolerance should be less than old tolerance!!.')
            else
                obj.tol = tol;
            end
        end
        function summary(obj)
            nf = java.text.DecimalFormat;
            fprintf(' RMSE  : %6.2e\n',obj.tol);
            fprintf(' MSE/2 : %6.2e\n',obj.tol^2/2);
            fprintf('.--------------------------------------------------------------------------------.\n')
            fprintf('| Level |   Ml   |     NSAMP     |     E[Yh]     |     V[Yh]     |  V[Yh]/NSAMP  |\n')
            fprintf('|-------+--------+---------------+---------------+---------------+---------------|\n')
            Q = 0;
            err = 0;
            for i = 1 : obj.level
                fprintf('|%6d |%7d |%14s |%14.2e |%14.2e |%14.2e |\n',i,mlmcget(obj.opt,'M1',8)*2^(i-1),...
                    char(nf.format(obj.mlmc_obj{i}.nsamp)),obj.mlmc_obj{i}.mean,...
                    obj.mlmc_obj{i}.var,obj.mlmc_obj{i}.serr);
                Q = Q + obj.mlmc_obj{i}.mean;
                err = err + obj.mlmc_obj{i}.var/obj.mlmc_obj{i}.nsamp;
            end
            fprintf('|-------+--------+---------------+---------------+---------------+---------------|\n')
            fprintf('| Total |        |               |%14.2e |               |%14.2e |\n',Q,err)
            fprintf(' ------------------------------------------------------------------------------- \n')
        end
        
        function q = meanQ(obj)
            q = 0;
            for i = 1 : obj.level
                q = q + obj.mlmc_obj{i}.mean;
            end
        end
    end
    
    methods (Access = private)
        function initRun(obj)
            % Level 1
            obj.Ml = mlmcget(obj.opt,'M1',8);
            obj.mlmc_obj{1} = eval([mlmcget(obj.opt,'olmc','oneLevelMC2D') '(' num2str(obj.Ml) ')']);
            t = tic;
            obj.mlmc_obj{1}.run(mlmcget(obj.opt,'initN',10));
            obj.time(1) = toc(t)/mlmcget(obj.opt,'initN',10);
            
            
            % Level 2
            addLevel(obj,mlmcget(obj.opt,'initN',10));
            
            % Level 3
            addLevel(obj,mlmcget(obj.opt,'initN',10));
            
            while (serr(obj) > obj.tol^2/2)
                update_optimal_nsamp(obj)
                update(obj)
            end
        end
        
        function alpha = compute_alpha(obj)
            summary(obj)
            alpha = zeros(obj.level-2,1);
            for i = 3 : obj.level
                alpha(i-2) = -log(abs(obj.mlmc_obj{i}.mean/obj.mlmc_obj{i-1}.mean))/log(mlmcget(obj.opt,'s',4));
            end
            alpha
            %             [obj.mlmc_obj{2}.mean obj.mlmc_obj{3}.mean]
        end
        
        function ttime = total_time(obj)
            ttime = 0;
            for i = 1 : obj.level
                ttime = ttime + sqrt(obj.mlmc_obj{i}.var*obj.time(i));
            end
        end
        
        function update_optimal_nsamp(obj)
            ttime = total_time(obj);
            for i = 1 : obj.level
                obj.optimal_nsamp(i) = max(ceil(2*sqrt(obj.mlmc_obj{i}.var/obj.time(i))*ttime/(obj.tol^2)),obj.mlmc_obj{i}.nsamp);
            end
        end
        
        function update(obj)
            for i = 1 : obj.level
                extra_nsamp = obj.optimal_nsamp(i)-obj.mlmc_obj{i}.nsamp;
                if extra_nsamp > 0
                    fprintf('On level [%02d], %d more samples are required.\n',i,extra_nsamp)
                end
                obj.mlmc_obj{i}.run(extra_nsamp);
            end
        end
        
        function se = serr(obj)
            se = 0;
            for i = 1 : obj.level
                se = se + obj.mlmc_obj{i}.serr;
            end
        end
        
        function addLevel(obj,nsamp)
            obj.level = obj.level + 1;
            obj.Ml = obj.Ml * 2;
            obj.mlmc_obj{obj.level} = eval([mlmcget(obj.opt,'tlmc','twoLevelMC2D') '(' num2str(obj.Ml) ')']);
            t = tic;
            obj.mlmc_obj{obj.level}.run(nsamp);
            obj.time(obj.level) = toc(t)/nsamp;
        end
        
        function converged = checkBiasError(obj)
            fprintf('\n[Checking the bias error]\n');
            converged = false;
            alpha = compute_alpha(obj);
            fprintf('[1] alpha              = %8.2f\n',alpha(end))
            if alpha(end) > 0
                rfactor = obj.s^alpha(end);
                fprintf('[2] rf                 = %8.2f\n',rfactor);
                fprintf('[3] E[Yh]              = %6.2e\n',obj.mlmc_obj{obj.level}.mean);
                fprintf('[4] E[Y2h]/rf          = %6.2e\n',obj.mlmc_obj{obj.level}.mean/rfactor);
                fprintf('[5] (rf-1)*tol/sqrt(2) = %6.2e\n',(rfactor-1)*obj.tol/sqrt(2));
                if max(obj.mlmc_obj{obj.level}.mean,obj.mlmc_obj{obj.level-1}.mean/rfactor) < (rfactor-1)*obj.tol/sqrt(2)
                    converged = true;
                end
            else
                
            end
            if converged
                fprintf('Converged\n');
            else
                fprintf('Not converged\n');
            end
            
        end
        
    end
end
