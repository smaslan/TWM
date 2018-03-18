function [u] = mod_synth(fs,N,ofs,f0,A0,ph0,fm,Am,phm)

    t(:,1) = [0:N-1]/fs;
    u = ofs + sin(t*f0*2*pi + ph0).*(A0 + Am*sin(t*fm*2*pi + phm));

end