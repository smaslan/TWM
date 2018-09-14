function [res] = proc_modtdps_test(par)
% TWM-MODTDPS validation - execution of test runs for given test setup.

    
    name_list = {'A0','Am','mod','f0','fm'};
    
    % signal configuration:
    cfg = par.cfg;
    
    punc = [];    
    for r = 1:par.val.max_count
            
        try

            % --- synthesize the signal:    
            datain = gen_mod(par.din, cfg, par.rand_unc);
            
            % --- execute the algorithm:
            dout = qwtb('TWM-MODTDPS', datain, par.calcset);
            
            % get ref. and calculated quantities:
            ref_list = [cfg.A0,    cfg.Am,    100*cfg.Am/cfg.A0, cfg.f0,    cfg.fm];
            dut_list = [dout.A0.v, dout.A_mod.v, dout.mod.v,        dout.f0.v, dout.f_mod.v];
            unc_list = [dout.A0.u, dout.A_mod.u, dout.mod.u,        dout.f0.u, dout.f_mod.u];
                        
            % compare generated and calculated:
            dev_list = (dut_list - ref_list);
            
            % percent-of-uncertainty list:
            punc_list = dev_list./unc_list;
            
            % store %-unc to list:
            punc(end+1,:) = punc_list;
            
            % all passed?
            is_pass = all(dev_list./unc_list < 1);
            
        catch err
        
            disp(err);
            %rethrow(err);
        
            % failed:
            is_pass = 0;
            
            % default items:
            simout = struct();
        
        end
        
        % ### to be removed when qwtb does not destroy paths (it still does for some reason...)
        qwtb('TWM-MODTDPS','addpath');
        
        % one test done:
        par.val.max_count = par.val.max_count - 1;

        % done?
        if size(punc,1) >= par.val.min_count
            break;
        end
    
    end
    
    if ~size(punc,1)
        % empty list - failed all times!
        punc = [];
        pass = zeros(size(name_list));
                
    elseif size(punc,1) == 1
        % one test only - all deviations ok? 
        pass = abs(punc) < 1.0;
        
    else
        % more tests - calculate probability:        
        pass_prob = mean(abs(punc) < 1.0,1);
        
        % pass?
        pass = pass_prob > par.calcset.loc;
                         
    end
    
    % --- store results:
    % test setup:
    res.par = par;
    % pass flags:
    res.pass = single(pass);
    % %-of-unc histogram:
    res.punc = single(punc);
    % store name list:
    res.name_list = name_list;      
    
end