function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-MODTDPS.
%
% See also qwtb

    N = 10000;

    fs = 10000;
    
    f0 = 50.3;
    
    fm = 2.321;
    
    A0 = 1.0;
    Am = 0.5;
    
    dc = 0.1;
    
    u = mod_synth(fs,N, dc, f0,A0,0, fm,Am,0.1);
    
    din.wave_shape.v = 'sine';
    din.comp_err.v = 1;
    din.fs.v = fs;
    din.y.v = u;
    
    dout = qwtb('TWM-MODTDPS',din);
    
    plot(dout.env_t.v,dout.env.v)
    
    dout = rmfield(dout,'env');        
    dout = rmfield(dout,'env_t');
    
    dout
    
end
   