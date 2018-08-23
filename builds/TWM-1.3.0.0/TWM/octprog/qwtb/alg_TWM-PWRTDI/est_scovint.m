function [unc] = est_scovint(x,x0)
% Simple wrapper for scovint() uncertainty evaluator.
% Calculates for fixed p = 95%.  
% Chooses larger of the left-/righ-bounds, user must enter expected (true) value 'x0'.    
     
    [nix,sql,sqr] = scovint(x,0.95,x0);
    if isempty(sql)
        [nix,sql,sqr] = scovint(x,0.95);
    end
    unc = max(abs(sqr - x0),abs(sql - x0));
        
end