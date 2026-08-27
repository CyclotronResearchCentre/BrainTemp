function [wsFile, wsNum] = find_nearest_ws_file(refScanNum, wsDir)
% FIND_NEAREST_WS_FILE
% Finds the nearest WS file (excluding WS_RES) to the provided REF scan number.

    wsFiles = dir(fullfile(wsDir, '*.nii.gz'));
    wsCandidates = struct([]);
    wsNums = [];

    for k = 1:numel(wsFiles)
        thisName = wsFiles(k).name;
        num = extract_scan_number(thisName);

        if isempty(num)
            continue;
        end

        if contains(thisName, '_ws_') && ~contains(thisName, '_ws_RES_')
            wsCandidates = [wsCandidates; wsFiles(k)]; %#ok<AGROW>
            wsNums = [wsNums; num]; %#ok<AGROW>
        end
    end

    if isempty(wsCandidates)
        error('No WS files found.');
    end

    [~, idx] = min(abs(wsNums - refScanNum));
    wsFile = wsCandidates(idx);
    wsNum = wsNums(idx);
end