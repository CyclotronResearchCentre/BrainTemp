function results = run_thermometry_unsuppressed_single(dataPath)
% RUN_THERMOMETRY_UNSUPPRESSED_SINGLE
% Thermometry from one unsuppressed multi-transient MRS acquisition.
%
% Usage:
%   results = run_thermometry_unsuppressed_single('/path/to/file.nii.gz')

    cfg = get_default_config();

    addpath(genpath('/home/mohamed/Codes/MyGitlab/mrs_pipeline'));
    addpath(genpath(cfg.ospreyPath));
    rehash;

    ensure_dir_exists(cfg.outputDir);
    ensure_dir_exists(cfg.outputMatDir);
    ensure_dir_exists(cfg.outputFigDir);

    fprintf('Unsuppressed file:\n%s\n', dataPath);

    raw = patch_nii_mrs_provenance(load_nifti_mrs_generic(dataPath));

    proc = preprocess_unsuppressed_for_thermometry(raw, cfg);

    [waterFit, naaFit, thermo] = fit_water_and_naa_unsuppressed(proc.avg_after, cfg);

    results = struct();
    results.dataPath = dataPath;
    results.raw = raw;
    results.proc = proc;
    results.waterFit = waterFit;
    results.naaFit = naaFit;
    results.thermo = thermo;

    [~, nameOnly, ~] = fileparts(dataPath);
    nameOnly = strrep(nameOnly, '.nii', '');

    savePath = fullfile(cfg.outputMatDir, [nameOnly '_unsuppressed_thermometry.mat']);
    save(savePath, 'results', '-v7.3');

    results.savePath = savePath;

    fprintf('\nSaved results to:\n%s\n', savePath);
    fprintf('Water ppm = %.5f\n', waterFit.centerPpm);
    fprintf('NAA ppm   = %.5f\n', naaFit.centerPpm);
    fprintf('Delta ppm = %.5f\n', thermo.deltaPPM);
    fprintf('Temp      = %.3f °C\n', thermo.temperatureC);

    plot_unsuppressed_thermometry_steps(results, cfg);
end