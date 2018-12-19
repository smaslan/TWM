function [res] = proc_wfft_test_run(par)
% This is inner execution unit of TWM-WFFT validation.
% It will load the test parameters and execute TWM-WFFT algorithm once, returns pass/fail.

    % list of quantities:
    name_list = {'A0', 'ph0', 'Ax', 'phx', 'dc'};       
    
    try
        % --- generate the signal:        
        [datain,simout] = gen_pwr(par.din, par.cfg, par.rand_unc);
    
        % --- execute the algorithm:
        calcset.mcm.randomize = 0;    
        dout = qwtb('TWM-WFFT',datain,par.calcset);
        qwtb('TWM-WFFT','addpath');
        
        H = numel(dout.A.v);
        
        % get ref. and calculated quantities:
        ref_list = [par.cfg.chn{1}.A(1), par.cfg.chn{1}.ph(1), par.cfg.chn{1}.A(2:H).', par.cfg.chn{1}.ph(2:H).', par.cfg.chn{1}.dc];
        dut_list = [dout.A.v(1),         dout.ph.v(1),         dout.A.v(2:H).',         dout.ph.v(2:H).',         dout.dc.v];
        unc_list = [dout.A.u(1),         dout.ph.u(1),         dout.A.u(2:H).',         dout.ph.u(2:H).',         dout.dc.u];
                    
        % compare generated and calculated:
        dev_list = (dut_list - ref_list);
        
        % identify worst harmonics:
        [v,idAx] = max(abs(dev_list(3:3+H-1)));
        [v,idPx] = max(abs(dev_list(3+H:end-1)));
        if isempty(idAx)
            idAx = 1;
        else
            idAx = idAx + 1;
        end
        if isempty(idPx)
            idPx = 2;
        else
            idPx = idPx + 2+(H-1)-1;
        end
            
                
        % shrink list to contain just the worst harmonics:
        id = [1, 2, idAx, idPx, numel(ref_list)];
        ref_list = ref_list(id);
        dut_list = dut_list(id);
        unc_list = unc_list(id);
        
        % compare generated and calculated:
        dev_list = (dut_list - ref_list);
               
        % percent-of-uncertainty list:
        punc_list = dev_list./unc_list;
        
        % store %-unc to list:
        punc = punc_list;
        
        % all passed?
        is_pass = all(dev_list./unc_list < 1);
        
    catch err
    
        disp(err);
    
        % no %-unc:
        punc = [];
    
    end

    
    % --- store results:
    % %-of-unc for histogram:
    res.punc = single(punc);
    % store name list:
    res.name_list = name_list;      
    
end