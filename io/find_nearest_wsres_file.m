function [wsresFile, wsresNum] = find_nearest_wsres_file(refScanNum, wsDir)
% FIND_NEAREST_WSRES_FILE
% Finds the nearest WS_RES file to the provided REF scan number.

    wsFiles = dir(fullfile(wsDir, '*.nii.gz'));
    wsresCandidates = struct([]);
    wsresNums = [];

    for k = 1:numel(wsFiles)
        thisName = wsFiles(k).name;
        num = extract_scan_number(thisName);

        if isempty(num)
            continue;
        end

        if contains(thisName, '_ws_RES_')
            wsresCandidates = [wsresCandidates; wsFiles(k)]; %#ok<AGROW>
            wsresNums = [wsresNums; num]; %#ok<AGROW>
        end
    end

    if isempty(wsresCandidates)
        error('No WS_RES files found.');
    end

    [~, idx] = min(abs(wsresNums - refScanNum));
    wsresFile = wsresCandidates(idx);
    wsresNum = wsresNums(idx);
end