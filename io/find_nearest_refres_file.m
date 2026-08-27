function [refresFile, refresNum] = find_nearest_refres_file(scanNum, refDir)
% FIND_NEAREST_REFRES_FILE
% Finds the nearest REF_RES file to a given scan number.

    refFiles = dir(fullfile(refDir, '*.nii.gz'));
    refresCandidates = struct([]);
    refresNums = [];

    for k = 1:numel(refFiles)
        thisName = refFiles(k).name;
        num = extract_scan_number(thisName);

        if isempty(num)
            continue;
        end

        if contains(thisName, '_ref_RES_')
            refresCandidates = [refresCandidates; refFiles(k)]; %#ok<AGROW>
            refresNums = [refresNums; num]; %#ok<AGROW>
        end
    end

    if isempty(refresCandidates)
        error('No REF_RES files found in %s.', refDir);
    end

    [~, idx] = min(abs(refresNums - scanNum));
    refresFile = refresCandidates(idx);
    refresNum = refresNums(idx);
end