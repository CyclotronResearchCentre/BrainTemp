function results = preprocess_wsres_from_ref(refScanNum, cfg)
% PREPROCESS_WSRES_FROM_REF
% End-to-end preprocessing for one REF scan and the nearest WS_RES scan.
%
% Steps:
%   1) alignment
%   2) averaging
%   3) FFT availability check
%   4) polarity correction
%   5) residual water removal
%   + QC: NAA sign check

    % Find files
    refFile = find_ref_file(refScanNum, cfg.refDir);
    [wsresFile, wsresNum] = find_nearest_wsres_file(refScanNum, cfg.wsDir);

    fprintf('Selected REF file: %s\n', refFile.name);
    fprintf('Nearest WS_RES file: %s (scan %d)\n', wsresFile.name, wsresNum);

    % Build file paths
    refPath = fullfile(refFile.folder, refFile.name);
    wsresPath = fullfile(wsresFile.folder, wsresFile.name);

    % Load
    ref   = load_nifti_mrs_generic(refPath);
    wsres = load_nifti_mrs_generic(wsresPath);

    ref   = patch_nii_mrs_provenance(ref);
    wsres = patch_nii_mrs_provenance(wsres);

    fprintf('\nLoaded files:\n');
    fprintf('REF   : %s\n', refPath);
    fprintf('WS_RES: %s\n', wsresPath);

    fprintf('\nWS_RES dimensions:\n');
    disp(wsres.sz);
    disp(wsres.dims);

    if ~isfield(wsres, 'dims') || ~isfield(wsres.dims, 'averages') || wsres.dims.averages == 0
        error('WS_RES does not contain an averages dimension.');
    end

    % Step 1: alignment
    [wsres_aligned, fs, phs] = step1_align_averages(wsres, cfg);

    % Step 2: averaging
    wsres_avg_before = step2_average(wsres);
    wsres_avg_after  = step2_average(wsres_aligned);

    % Step 3: FFT availability
    step3_fft_info(wsres_avg_after);

    % Step 4: polarity correction
    [wsres_polcorr, flipped, peakValue] = step4_correct_polarity(wsres_avg_after, cfg);

    % QC: check NAA sign, but do not force polarity from it
    naaQC_before = check_naa_sign(wsres_avg_after, cfg.naaPpmRange);
    naaQC_afterPol = check_naa_sign(wsres_polcorr, cfg.naaPpmRange);

    % Step 5: residual water removal
    if cfg.applyWaterRemoval
        wsres_water_removed = step5_remove_residual_water(wsres_polcorr, cfg.waterPpmRange);
        naaQC_afterWater = check_naa_sign(wsres_water_removed, cfg.naaPpmRange);
    else
        wsres_water_removed = wsres_polcorr;
        naaQC_afterWater = naaQC_afterPol;
    end

    % Collect results
    results = struct();
    results.refScanNum = refScanNum;
    results.wsresNum = wsresNum;

    results.refPath = refPath;
    results.wsresPath = wsresPath;

    results.ref = ref;
    results.wsres = wsres;
    results.wsres_aligned = wsres_aligned;
    results.wsres_avg_before = wsres_avg_before;
    results.wsres_avg_after = wsres_avg_after;
    results.wsres_polcorr = wsres_polcorr;
    results.wsres_water_removed = wsres_water_removed;

    results.fs = fs;
    results.phs = phs;
    results.flipped = flipped;
    results.peakValue = peakValue;

    results.naaQC_before = naaQC_before;
    results.naaQC_afterPol = naaQC_afterPol;
    results.naaQC_afterWater = naaQC_afterWater;

    % Save
    saveStem = sprintf('REF_%d__WSRES_%d_preproc', refScanNum, wsresNum);
    savePath = fullfile(cfg.outputMatDir, [saveStem '.mat']);
    save(savePath, 'results', '-v7.3');

    results.savePath = savePath;

    fprintf('\nSaved results to:\n%s\n', savePath);

    fprintf('\nNAA QC summary:\n');
    fprintf('Before polarity correction : %s (peak %.4g at %.4f ppm)\n', ...
        results.naaQC_before.signLabel, results.naaQC_before.peakValue, results.naaQC_before.peakPpm);
    fprintf('After polarity correction  : %s (peak %.4g at %.4f ppm)\n', ...
        results.naaQC_afterPol.signLabel, results.naaQC_afterPol.peakValue, results.naaQC_afterPol.peakPpm);
    fprintf('After water removal        : %s (peak %.4g at %.4f ppm)\n', ...
        results.naaQC_afterWater.signLabel, results.naaQC_afterWater.peakValue, results.naaQC_afterWater.peakPpm);
end