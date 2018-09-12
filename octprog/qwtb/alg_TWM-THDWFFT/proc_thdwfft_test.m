function [res] = proc_thdwfft(par)
    
    name_list = {'THD','H0','Hx'};
    
    punc = [];    
    for r = 1:par.val.max_count
            
        try

            % --- simulate waveforms ---
            [sig,fs_out,k1_out,h_amps] = thd_sim_wave(par.sim);
            
            % store simulated waveform data:
            par_proc = par;
            par_proc.din = par_proc.sim.corr;
            par_proc.din.y.v = sig;
            par_proc.din.fs.v = fs_out;
            
            % --- calculate THD ---
            dout = qwtb('TWM-THDWFFT',par_proc.din,par_proc.calcset);
            
            % get ref. and calculated quantities:
            ref_list = [k1_out,     h_amps'];
            dut_list = [dout.thd.v, dout.h.v'];
            unc_list = [dout.thd.u, dout.h.u'];
                        
            % compare generated and calculated:
            dev_list = (dut_list - ref_list);
            
            % percent-of-uncertainty list:
            punc_list = dev_list./unc_list;
            
            
            % identify max. harmonic deviation:
            [v,id] = max(abs(punc_list(3:end)));
            
            % reduce list to fundamental and worst harmonic:
            punc_list = punc_list([1,2,id+2]);
            dev_list  = dev_list([1,2,id+2]);
            unc_list  = unc_list([1,2,id+2]);
                        
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
        % ### to be removed when qwtb does not destroy paths
        qwtb('TWM-THDWFFT','addpath');
        
        % one test done:
        par.val.max_count = par.val.max_count - 1;

        % done?
        if (is_pass && par.val.fast_mode) || par.val.max_count <= 0
            break;
        end
    
    end
    
    if ~size(punc,1)
        % empty list - failed all times!
        punc = zeros(size(name_list));
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
    res.pass = pass;
    % %-of-unc histogram:
    res.punc = punc;
    % store name list:
    res.name_list = name_list;      

end