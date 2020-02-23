function [ok, mutex_path] = qwtb_exclusive_lock(folder, tag, timeout)
% Create file mutex to protect shared accessed objects.
% Parameters:
% 'folder' - folder to create mutext file
% 'tag' - mutex file name part (must be unique if multiple mutexes are to be used)
% 'timeout' - timeout in seconds to wait
% Return:
%  'ok' - will be non-zero when access was gained
%  'mutex_path' - path to the file mutex 
    
    % generate mutex path
    mutex_temp = fullfile(folder,sprintf('%s_%016d.lock',tag,rand*1e16));
    mutex_path = fullfile(folder,sprintf('%s.lock',tag));
    
    % make temp mutex file
    fw = fopen(mutex_temp,'w');
    fputs(fw, 'mutex file - no touchy when running!');
    fclose(fw);
    
    % no success by default
    ok = 0;
    
    % try to move mutex to final destination
    tid = tic();
    t0  = toc(tid);
    while (toc(tid) - t0) < timeout
        [err] = rename(mutex_temp, mutex_path);
        if ~err
            % success
            ok = 1;
            break;
        end
        % wait before next try
        pause(0.05);
    end

    if err
        % remove unused mutex temp file
        unlink(mutex_temp);
    end
    
end