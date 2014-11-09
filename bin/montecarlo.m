classdef montecarlo < handle
    %MONTECARLO Abstract class for creating Monte Carlo objects
    %   
    
    properties (SetAccess = protected, GetAccess = protected)
        sumQ = 0;
        sumQ2 = 0;
        ns = 0;
    end
    
    methods(Abstract)
        run(obj,n);
%         disp(obj);
    end
    
    methods
        function mVal = mean(obj)
            mVal = obj.sumQ/obj.ns;
        end
        
        function se = serr(obj)
            se = (obj.ns*obj.sumQ2-obj.sumQ^2)/(obj.nsamp*(obj.ns-1))/obj.ns;
        end
        
        function vVal = var(obj)
            vVal = (obj.ns*obj.sumQ2-obj.sumQ^2)/(obj.nsamp*(obj.ns-1));
        end
        
        function nSamp = nsamp(obj)
            nSamp = obj.ns;
        end
          
        
    end
    
end

