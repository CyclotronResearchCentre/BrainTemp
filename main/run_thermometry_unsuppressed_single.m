function results = run_thermometry_unsuppressed_single(dataPath)
% RUN_THERMOMETRY_UNSUPPRESSED_SINGLE  Thermometry from a raw file path.
%
%   results = RUN_THERMOMETRY_UNSUPPRESSED_SINGLE(dataPath) runs the same
%   preprocess-fit-thermometry chain as RUN_THERMOMETRY_REFRES_SINGLE, but
%   takes a NIfTI-MRS file path directly instead of looking one up by scan
%   number. RUN_THERMOMETRY_REFRES_SINGLE calls this internally after
%   resolving the scan number to a path; call this one directly if you
%   already have the file path (e.g. data outside the standard REF/WS
%   folder layout).
%
%   Input
%   -----
%   dataPath : full path to an unsuppressed, multi-transient NIfTI-MRS
%              file (e.g. a REF_RES acquisition)
%
%   Output
%   ------
%   results : struct with results.thermo.{deltaPPM,temperatureC},
%             results.waterFit / results.naaFit, and preprocessing steps.
%             Saved to <outputMatDir>/<filename>_unsuppressed_thermometry.mat
%
%   Example
%   -------
%       results = run_thermometry_unsuppressed_single('/path/to/file.nii.gz')
%
%   See also: RUN_THERMOMETRY_REFRES_SINGLE, COMPUTE_TEMPERATURE_FROM_SHIFT

    cfg = get_default_config();

    addpath(genpath(fileparts(fileparts(mfilename('fullpath'))))); % repo root, portable
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