function [] = qwtb_exclusive_release(mutex_file)
% Release file mutex created by qwtb_exclusive_lock().
% Parameters:
%  'mutex_path' - path to the file mutex

    % check validity of mutex file
    [fld,name,ext] = fileparts(mutex_file);
    if ~strcmp(mutex_file,'.lock')
        error('File mutex: possibly incorrect file path passed in the function!');
    end 
    
    % try to remove mutex file
    err = unlink(mutex_file);
    if err
        error('File mutex: removal of mutex file failed!')
    end
    
end