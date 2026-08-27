function summaryN = run_thermometry_transient_stability_sequential(refScanNum, nList)
% RUN_THERMOMETRY_TRANSIENT_STABILITY_SEQUENTIAL
% Tests temperature stability as a function of the number of WS_RES transients.
%
% This uses the first N transients:
%   N = 4  -> transients 1:4
%   N = 8  -> transients 1:8
%   N = 16 -> transients 1:16
%   etc.
%
% Usage:
%   summaryN = run_thermometry_transient_stability_sequential(39);
%   summaryN = run_thermometry_transient_stability_sequential(39, [4 8 16 32 64]);

    if nargin < 2 || isempty(nList)
        nList = [4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64];
    end

    cfg = get_default_config();

    addpath(genpath('/home/mohamed/Codes/MyGitlab/mrs_pipeline'));
    addpath(genpath(cfg.ospreyPath));
    rehash;

    ensure_dir_exists(cfg.outputDir);
    ensure_dir_exists(cfg.outputMatDir);
    ensure_dir_exists(cfg.outputFigDir);

    refFile = find_ref_file(refScanNum, cfg.refDir);
    [wsresFile, wsresNum] = find_nearest_wsres_file(refScanNum, cfg.wsDir);

    refPath   = fullfile(refFile.folder, refFile.name);
    wsresPath = fullfile(wsresFile.folder, wsresFile.name);

    fprintf('REF   : %s\n', refPath);
    fprintf('WSRES : %s\n', wsresPath);

    ref   = patch_nii_mrs_provenance(load_nifti_mrs_generic(refPath));
    wsres = patch_nii_mrs_provenance(load_nifti_mrs_generic(wsresPath));

    % REF branch: water peak
    ref_proc = preprocess_ref_for_water(ref, cfg);
    waterFit = fit_water_peak(ref_proc.avg, cfg);

    % Align all WS_RES transients once
    [wsres_aligned, fs, phs] = step1_align_averages(wsres, cfg);

    avgDim = wsres_aligned.dims.averages;
    if avgDim == 0
        error('WS_RES has no averages dimension.');
    end

    nTotal = size(wsres_aligned.fids, avgDim);
    nList = nList(nList <= nTotal);

    if isempty(nList)
        error('No requested N values are <= number of available transients (%d).', nTotal);
    end

    rows = [];

    for iN = 1:numel(nList)

        N = nList(iN);
        idx = 1:N;

        fprintf('\nProcessing first %d transients...\n', N);

        % Select first N aligned transients
        wsres_sub = select_averages(wsres_aligned, idx);

        % Average selected transients
        wsres_avg = step2_average(wsres_sub);

        % ECC using REF
        [wsres_ecc, ~] = step_ecc_klose(wsres_avg, ref_proc.avg);

        % Polarity correction
        [wsres_polcorr, flipped, ~] = step4_correct_polarity(wsres_ecc, cfg);

        % Residual water removal
        if isfield(cfg, 'applyWaterRemoval') && cfg.applyWaterRemoval
            wsres_clean = step5_remove_residual_water(wsres_polcorr, cfg.waterPpmRange);
        else
            wsres_clean = wsres_polcorr;
        end

        % Fit NAA and compute temperature
        naaFit = fit_naa_peak(wsres_clean, cfg);
        thermo = compute_temperature_from_shift(waterFit, naaFit, cfg);

        row = table();

        row.REF_scan        = refScanNum;
        row.WSRES_scan      = wsresNum;
        row.N_transients    = N;

        row.water_ppm       = waterFit.centerPpm;
        row.naa_ppm         = naaFit.centerPpm;
        row.deltaPPM        = thermo.deltaPPM;
        row.temperature_C   = thermo.temperatureC;

        row.naa_gamma       = naaFit.gamma;
        row.naa_amplitude   = naaFit.A;
        row.flipped         = flipped;

        row.mean_abs_fs_Hz    = mean(abs(fs(idx)));
        row.mean_abs_phs_deg  = mean(abs(phs(idx)));

        if isfield(naaFit, 'model')
            row.fit_model = string(naaFit.model);
        else
            row.fit_model = "";
        end

        rows = [rows; row]; %#ok<AGROW>

        fprintf('N = %d | NAA = %.5f ppm | Delta = %.5f ppm | T = %.3f °C\n', ...
            N, naaFit.centerPpm, thermo.deltaPPM, thermo.temperatureC);
    end

    summaryN = rows;

    outCsv = fullfile(cfg.outputDir, ...
        sprintf('REF_%d__WSRES_%d_transient_stability_sequential.csv', refScanNum, wsresNum));

    outMat = fullfile(cfg.outputDir, ...
        sprintf('REF_%d__WSRES_%d_transient_stability_sequential.mat', refScanNum, wsresNum));

    writetable(summaryN, outCsv);
    save(outMat, 'summaryN');

    fprintf('\nSaved:\n%s\n%s\n', outCsv, outMat);

    plot_transient_stability_sequential(summaryN, cfg, refScanNum, wsresNum);
end
