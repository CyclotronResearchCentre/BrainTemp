function refFile = find_ref_file(refScanNum, refDir)
% FIND_REF_FILE
% Finds the exact REF file matching the requested scan number.

    refFiles = dir(fullfile(refDir, '*.nii.gz'));
    refFile = [];

    for k = 1:numel(refFiles)
        num = extract_scan_number(refFiles(k).name);
        if ~isempty(num) && num == refScanNum
            refFile = refFiles(k);
            return;
        end
    end

    error('No REF file found with scan number %d.', refScanNum);
end