function run_thermometry_single(refScanNum, cfg)
% RUN_THERMOMETRY_SINGLE
% Runs a thermometry workflow:
%   1) load REF and nearest WS_RES
%   2) preprocess REF for water fit
%   3) preprocess WS_RES for NAA fit, including ECC with REF
%   4) fit water and NAA peaks
%   5) compute chemical shift difference
%   6) estimate temperature
%   7) save preprocessing and fitting figures

    if nargin < 2 || isempty(cfg)
        cfg = get_default_config();
    end

    addpath(genpath('/home/mohamed/Codes/MyGitlab/mrs_pipeline'));
    addpath(genpath(cfg.ospreyPath));
    rehash;

    ensure_dir_exists(cfg.outputDir);
    ensure_dir_exists(cfg.outputMatDir);
    ensure_dir_exists(cfg.outputFigDir);

    % Find files
    refFile = find_ref_file(refScanNum, cfg.refDir);
    [wsresFile, wsresNum] = find_nearest_wsres_file(refScanNum, cfg.wsDir);

    refPath   = fullfile(refFile.folder, refFile.name);
    wsresPath = fullfile(wsresFile.folder, wsresFile.name);

    fprintf('REF   : %s\n', refPath);
    fprintf('WSRES : %s\n', wsresPath);

    % Load
    ref   = patch_nii_mrs_provenance(load_nifti_mrs_generic(refPath));
    wsres = patch_nii_mrs_provenance(load_nifti_mrs_generic(wsresPath));

    % Preprocess REF first
    ref_proc = preprocess_ref_for_water(ref, cfg);

    % Preprocess WS_RES using averaged REF for ECC
    wsres_proc = preprocess_wsres_for_naa(wsres, ref_proc.avg, cfg);

    % Fit peaks
    waterFit = fit_water_peak(ref_proc.avg, cfg);
    naaFit   = fit_naa_peak(wsres_proc.water_removed, cfg);

    % Compute thermometry output
    thermo = compute_temperature_from_shift(waterFit, naaFit, cfg);

    % Collect results
    results = struct();
    results.refScanNum = refScanNum;
    results.wsresNum = wsresNum;
    results.refPath = refPath;
    results.wsresPath = wsresPath;

    results.ref = ref;
    results.wsres = wsres;

    results.ref_proc = ref_proc;
    results.wsres_proc = wsres_proc;

    % Flatten key fields for plotting
    results.wsres_avg_before = wsres_proc.avg_before;
    results.wsres_avg_after = wsres_proc.avg_after;
    results.wsres_ecc = wsres_proc.ecc;
    results.wsres_polcorr = wsres_proc.polcorr;
    results.wsres_water_removed = wsres_proc.water_removed;

    results.fs = wsres_proc.fs;
    results.phs = wsres_proc.phs;
    results.flipped = wsres_proc.flipped;
    results.peakValue = wsres_proc.peakValue;

    results.naaQC_before = wsres_proc.naaQC_before;
    results.naaQC_afterECC = wsres_proc.naaQC_afterECC;
    results.naaQC_afterPol = wsres_proc.naaQC_afterPol;
    results.naaQC_afterWater = wsres_proc.naaQC_afterWater;

    results.waterFit = waterFit;
    results.naaFit = naaFit;
    results.thermo = thermo;

    % Save
    saveStem = sprintf('REF_%d__WSRES_%d_thermometry', refScanNum, wsresNum);
    savePath = fullfile(cfg.outputMatDir, [saveStem '.mat']);
    save(savePath, 'results', '-v7.3');

    fprintf('\nSaved thermometry results to:\n%s\n', savePath);

    % Figures
    plot_thermometry_fit_summary(results, cfg);
    plot_water_preprocessing_steps(results, cfg);
    plot_metabolite_preprocessing_steps(results, cfg);
    % --- Alignment QC (water region) ---
    cfg.alignmentQcPpmRange = [4.4 5.0];
    plot_transient_alignment_qc(results, cfg);

    % --- Alignment QC (NAA region) ---
    cfg.alignmentQcPpmRange = [1.6 2.2];
    plot_transient_alignment_qc(results, cfg);

    fprintf('\nEstimated temperature: %.3f °C\n', thermo.temperatureC);
end
