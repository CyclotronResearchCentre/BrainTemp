function results = run_thermometry_refres_single(refresScanNum)
% RUN_THERMOMETRY_REFRES_SINGLE  Main entry point: full thermometry from one scan.
%
%   results = RUN_THERMOMETRY_REFRES_SINGLE(refresScanNum) runs the
%   complete chain — find file, load, align, average, correct polarity,
%   remove residual water, fit water + NAA peaks, compute temperature —
%   on a single unsuppressed (REF_RES) acquisition, and saves the result.
%   This is the pipeline's flagship function; start here if you're new
%   to the codebase.
%
%   Input
%   -----
%   refresScanNum : scan number of the REF_RES acquisition to process
%                   (matches the number in its filename, e.g. 40 for
%                   ..._ref_RES_40_MR.nii.gz)
%
%   Output
%   ------
%   results : struct with results.thermo (deltaPPM, temperatureC),
%             results.waterFit / results.naaFit (fitted peaks), and the
%             intermediate preprocessing steps. Also saved to
%             <outputMatDir>/REFRES_<n>_unsuppressed_thermometry.mat
%
%   Example
%   -------
%       results = run_thermometry_refres_single(40)
%       fprintf('Estimated temperature: %.1f degC\n', results.thermo.temperatureC)
%
%   See also: RUN_THERMOMETRY_REFRES_ALL, COMPUTE_TEMPERATURE_FROM_SHIFT,
%   GET_DEFAULT_CONFIG

    cfg = get_default_config();

    addpath(genpath(fileparts(fileparts(mfilename('fullpath'))))); % repo root, portable
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
