function results = compare_ws_wsres_ref(refScanNum, cfg)
% COMPARE_WS_WSRES_REF
% Loads REF, nearest WS, and nearest WS_RES, then aligns WS_RES and
% prepares a comparison structure.

    refFile = find_ref_file(refScanNum, cfg.refDir);
    [wsFile, wsNum] = find_nearest_ws_file(refScanNum, cfg.wsDir);
    [wsresFile, wsresNum] = find_nearest_wsres_file(refScanNum, cfg.wsDir);

    refPath   = fullfile(refFile.folder, refFile.name);
    wsPath    = fullfile(wsFile.folder, wsFile.name);
    wsresPath = fullfile(wsresFile.folder, wsresFile.name);

    ref   = patch_nii_mrs_provenance(load_nifti_mrs_generic(refPath));
    ws    = patch_nii_mrs_provenance(load_nifti_mrs_generic(wsPath));
    wsres = patch_nii_mrs_provenance(load_nifti_mrs_generic(wsresPath));

    % Average REF if needed
    if isfield(ref, 'dims') && isfield(ref.dims, 'averages') && ref.dims.averages ~= 0
        ref_avg = step2_average(ref);
    else
        ref_avg = ref;
    end

    % Average WS if needed
    if isfield(ws, 'dims') && isfield(ws.dims, 'averages') && ws.dims.averages ~= 0
        ws_avg = step2_average(ws);
    else
        ws_avg = ws;
    end

    % Align and average WS_RES
    if isfield(wsres, 'dims') && isfield(wsres.dims, 'averages') && wsres.dims.averages ~= 0
        [wsres_aligned, fs, phs] = step1_align_averages(wsres, cfg);
        wsres_avg = step2_average(wsres_aligned);
    else
        wsres_aligned = wsres;
        wsres_avg = wsres;
        fs = [];
        phs = [];
    end

    results = struct();
    results.refScanNum = refScanNum;
    results.wsNum = wsNum;
    results.wsresNum = wsresNum;

    results.ref = ref;
    results.ref_avg = ref_avg;
    results.ws = ws;
    results.ws_avg = ws_avg;
    results.wsres = wsres;
    results.wsres_aligned = wsres_aligned;
    results.wsres_avg = wsres_avg;

    results.fs = fs;
    results.phs = phs;

    saveStem = sprintf('REF_%d__WS_%d__WSRES_%d_compare', refScanNum, wsNum, wsresNum);
    savePath = fullfile(cfg.outputMatDir, [saveStem '.mat']);
    save(savePath, 'results', '-v7.3');

    results.savePath = savePath;

    fprintf('Saved comparison results to:\n%s\n', savePath);
end