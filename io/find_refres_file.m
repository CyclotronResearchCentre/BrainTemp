function refresFile = find_refres_file(scanNum, refDir)
% FIND_REFRES_FILE
% Finds a REF_RES file with the specified scan number.

    pattern = sprintf('*ref_RES_%d*_MR.nii.gz', scanNum);

    files = dir(fullfile(refDir, pattern));

    if isempty(files)
        error('No REF_RES file found with scan number %d.', scanNum);
    end

    if numel(files) > 1
        warning('Multiple REF_RES files found. Using first match.');
    end

    refresFile = files(1);
end