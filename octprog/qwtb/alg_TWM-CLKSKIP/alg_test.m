function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-CLKSKIP.
%
% See also qwtb
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2023, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%

    % --- calculation setup:
    % verbose level
    calcset.verbose = 1;
    % uncertainty mode {'none' - no uncertainty calculation, 'guf' - estimator}
    calcset.unc = 'none';
    % level of confidence (default 0.68 i.e. k=1):
    calcset.loc = 0.95;
    % no QWTB input checking:
    calcset.checkinputs = 0;
    
    % ###TODO
     
   
%     figure
%     plot(datain.u.v)
%     hold on;
%     plot(datain.i.v,'r')
%     hold off;
   
    % --- execute the algorithm:
    dout = qwtb('TWM-CLKSKIP',datain,calcset);
    
    
  
    
end



function [rnd] = logrand(A_min,A_max,sz)
    if nargin < 3
        sz = [1 1];
    end
    if size(sz) < 2
        sz = [sz 1];
    end
    rnd = 10.^(log10(A_min) + (log10(A_max) - log10(A_min))*rand(sz));
end

function [rnd] = linrand(A_min,A_max,N)
    if nargin < 3
        N = [1 1];
    end
    if size(N) < 2
        sz = [N 1];
    end
    rnd = rand(N)*(A_max - A_min) + A_min;
end

function [din] = qwtb_add_unc(din,pin)
% this will create fake uncertainty for each non-parameter quantity
% ###TODO: to be removed, when QWTB will support no-unc checking
% It is just a temporary workaround.

    names = fieldnames(din);
    N = numel(names);

    p_names = {pin(~~[pin.parameter]).name};
    
    for k = 1:N
        if ~any(strcmpi(p_names,names{k}))
            v_data = getfield(din,names{k});
            if ~isfield(v_data,'u')
                v_data.u = 0*v_data.v;
                din = setfield(din,names{k},v_data);
            end
        end        
    end    
end
   