function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm CLKSKIP.
%
% See also qwtb
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2023, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%

    alginfo.id = 'TWM-CLKSKIP';
    alginfo.name = 'TWM tool wrapper: HP3458A clock skip detector';
    alginfo.desc = 'An algorithm for detection of 3458A DMM clock skipping HW bug. The bug is relevant only when sampling clock is generated by TIMER. Te bug manifests itself as extra 100ns time shift somewhere between the samples. The event might happen within first 100ms, but it may also take several minutes to occur. There might be even more of them or none. It is very diverse and changes in time.';
    alginfo.citation = 'no';
    alginfo.remarks = 'Usage: Generate sine of f0=1kHz, connect it to 3458A input. Record at least few seconds using 3458A with TIMER sampling rate generator. Use higher sampling rate, such as fs=50kSa/s (aperture of 10us). Select the ratio of fs/f0, so it is as close to integer as possible.';
    alginfo.license = 'MIT License';

    
    
    pid = 1;
    % sample data
    alginfo.inputs(pid).name = 'fs';
    alginfo.inputs(pid).desc = 'Sampling frequency';
    alginfo.inputs(pid).alternative = 1;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'Ts';
    alginfo.inputs(pid).desc = 'Sampling time';
    alginfo.inputs(pid).alternative = 1;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 't';
    alginfo.inputs(pid).desc = 'Time series';
    alginfo.inputs(pid).alternative = 1;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'y';
    alginfo.inputs(pid).desc = 'Sampled voltage';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
 
    
    % --- configuration:
    % initial frequency estimate
    alginfo.inputs(pid).name = 'f0';
    alginfo.inputs(pid).desc = 'Exact fundamental frequency [Hz] or empty to auto detect';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    % expected time skip value
    alginfo.inputs(pid).name = 'ref_delta_t';
    alginfo.inputs(pid).desc = 'Expected time skip value [s] or empty for default 100ns';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    % expected time skip value range
    alginfo.inputs(pid).name = 'tol_delta_t';
    alginfo.inputs(pid).desc = 'Expected tolerance of ref_delta_t [s] or empty for default 10ns';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    % equivalent circuit mode:
    alginfo.inputs(pid).name = 'plot';
    alginfo.inputs(pid).desc = 'Show result graphically';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
       
    % --- flags:
    % note: presence of these parameters signalizes caller capabilities of the algorithm
    % Algorithm does not support processing of multiple records at once.
       

    % --- parameters:
    
    
    
    % --- results:
    pid = 1;
    % outputs       
    alginfo.outputs(pid).name = 'f0';
    alginfo.outputs(pid).desc = 'Detected fundamental frequency [Hz]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'result';
    alginfo.outputs(pid).desc = 'Result in text form';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 't_skip';
    alginfo.outputs(pid).desc = 'Found time skip time [s]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'delta_t';
    alginfo.outputs(pid).desc = 'Found time skip value [s]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'delta_phi';
    alginfo.outputs(pid).desc = 'Found time skip phase value [rad]';
    pid = pid + 1;            
        
    alginfo.providesGUF = 0;
    alginfo.providesMCM = 0;

end

