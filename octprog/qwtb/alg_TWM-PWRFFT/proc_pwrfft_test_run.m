function [res] = proc_pwrfft_test_run(par)
% This is inner execution unit of TWM-PWRFFT validation.
% It will load the test parameters and execute TWM-PWRFFT algorithm once, returns pass/fail.

    % list of quantities:
    name_list = {'U',          'I',          'S',      'P',      'Q',      'PF',      'phi',                'Udc',      'Idc',      'Pdc'};       
    
    try
        % --- generate the signal:        
        [datain,simout] = gen_pwr(par.din, par.cfg, par.rand_unc);
    
        % --- execute the algorithm:
        calcset.mcm.randomize = 0;    
        dout = qwtb('TWM-PWRFFT',datain,par.calcset);
        qwtb('TWM-PWRFFT','addpath');
        
        % get ref. and calculated quantities:
        ref_list =  [simout.U_rms, simout.I_rms, simout.S, simout.P, simout.Q, simout.PF, simout.phi_ef*180/pi, simout.Udc, simout.Idc, simout.Pdc];
        dut_list =  [dout.U.v,     dout.I.v,     dout.S.v, dout.P.v, dout.Q.v, dout.PF.v, dout.phi_ef.v*180/pi, dout.Udc.v, dout.Idc.v, dout.Pdc.v];
        unc_list =  [dout.U.u,     dout.I.u,     dout.S.u, dout.P.u, dout.Q.u, dout.PF.u, dout.phi_ef.u*180/pi, dout.Udc.u, dout.Idc.u, dout.Pdc.u];
                    
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
    
        % failed:
        is_pass = 0;
        
        % no %-unc:
        punc_list = [];
        
        % default items:
        simout = struct();
    
    end

    
    % --- store results:
    % %-of-unc for histogram:
    res.punc = single(punc);
    % store name list:
    res.name_list = name_list;      
    
end