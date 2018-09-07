function [res] = proc_pwrtdi_test(par)

    punc = [];    
    for r = 1:par.val.max_count
    
        name_list = {'U',          'I',          'S',      'P',      'Q',      'PF',      'phi',                'Udc',      'Idc',      'Pdc'};
        
        try
            % --- generate the signal:        
            [datain,simout] = gen_pwr(par.din, par.cfg, par.rand_unc);
        
            % --- execute the algorithm:    
            calcset.mcm.randomize = 0;
            dout = qwtb('TWM-PWRTDI',datain,par.calcset);
            
            % get ref. and calculated quantities:
            ref_list =  [simout.U_rms, simout.I_rms, simout.S, simout.P, simout.Q, simout.PF, simout.phi_ef*180/pi, simout.Udc, simout.Idc, simout.Pdc];
            dut_list =  [dout.U.v,     dout.I.v,     dout.S.v, dout.P.v, dout.Q.v, dout.PF.v, dout.phi_ef.v*180/pi, dout.Udc.v, dout.Idc.v, dout.Pdc.v];
            unc_list =  [dout.U.u,     dout.I.u,     dout.S.u, dout.P.u, dout.Q.u, dout.PF.u, dout.phi_ef.u*180/pi, dout.Udc.u, dout.Idc.u, dout.Pdc.u];
                        
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
        
            % failed:
            is_pass = 0;
            
            % default items:
            simout = struct();
        
        end
        
        qwtb('TWM-PWRTDI','addpath');
        
        % one test done:
        par.val.max_count = par.val.max_count - 1;

        % done?
        if (is_pass && par.val.fast_mode) || par.val.max_count <= 0
            break;
        end
    
    end
    
    if ~size(punc,1)
        % empty list - failed all times!
        punc = zeros(1,10);
        pass = zeros(1,10);
                
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