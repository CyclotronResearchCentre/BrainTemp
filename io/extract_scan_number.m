function scanNum = extract_scan_number(fname)
% EXTRACT_SCAN_NUMBER
% Extracts the scan number from file names such as:
%   eja-slaser_motor_ref_39_MR.nii.gz
%   eja-slaser_motor_ws_RES_37_MR.nii.gz

    tok = regexp(fname, '_(\d+)_MR\.nii\.gz$', 'tokens', 'once');

    if isempty(tok)
        scanNum = [];
    else
        scanNum = str2double(tok{1});
    end
end