function ensure_dir_exists(dirPath)
% ENSURE_DIR_EXISTS
% Creates a directory if it does not already exist.

    if ~exist(dirPath, 'dir')
        mkdir(dirPath);
    end
end