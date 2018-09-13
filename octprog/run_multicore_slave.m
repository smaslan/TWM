function run_multicore_slave(jobs_fld)
    
    % no warnings:
    warning('off');
    
    fprintf('Jobs sharing folder path: ''%s''\n',jobs_fld);
    
    % start multicore server:
    startmulticoreslave(jobs_fld);
    
end