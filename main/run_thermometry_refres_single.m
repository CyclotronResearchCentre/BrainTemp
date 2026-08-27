function results = run_thermometry_refres_single(refresScanNum)
% RUN_THERMOMETRY_REFRES_SINGLE
% Thermometry from one REF_RES acquisition.
%
% Usage:
%   results = run_thermometry_refres_single(40)

    cfg = get_default_config();

    addpath(genpath('/home/mohamed/Codes/MyGitlab/mrs_pipeline'));
    addpath(genpath(cfg.ospreyPath));
    rehash;

    ensure_dir_exists(cfg.outputDir);
    ensure_dir_exists(cfg.outputMatDir);
    ensure_dir_exists(cfg.outputFigDir);

    refresFile = find_refres_file(refresScanNum, cfg.refDir);

    dataPath = fullfile(refresFile.folder, refresFile.name);

    fprintf('Selected REF_RES file:\n%s\n', refresFile.name);
    fprintf('Full path:\n%s\n', dataPath);

    results = run_thermometry_unsuppressed_single(dataPath);

    results.refresScanNum = refresScanNum;

    savePath = fullfile(cfg.outputMatDir, ...
        sprintf('REFRES_%d_unsuppressed_thermometry.mat', refresScanNum));

    save(savePath, 'results', '-v7.3');

    fprintf('\nSaved REF_RES thermometry results to:\n%s\n', savePath);
end
