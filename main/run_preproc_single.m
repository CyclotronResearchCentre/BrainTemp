function run_preproc_single(refScanNum)
% RUN_PREPROC_SINGLE  Preprocessing only, no fitting/thermometry.
%
%   RUN_PREPROC_SINGLE(refScanNum) runs preprocessing (alignment, polarity
%   correction, frequency/phase correction, residual-water removal) on the
%   REF/WS_RES pair for one REF scan, and saves the QC figures, without
%   fitting peaks or computing a temperature. Useful for checking data
%   quality before committing to a full thermometry run.
%
%   Input
%   -----
%   refScanNum : scan number of the REF acquisition
%
%   Example
%   -------
%       run_preproc_single(39)
%
%   See also: RUN_THERMOMETRY_SINGLE, PREPROCESS_WSRES_FROM_REF

    cfg = get_default_config();

    addpath(genpath(cfg.ospreyPath));
    rehash;

    ensure_dir_exists(cfg.outputDir);
    ensure_dir_exists(cfg.outputMatDir);
    ensure_dir_exists(cfg.outputFigDir);

    results = preprocess_wsres_from_ref(refScanNum, cfg);

    plot_before_after_alignment(results, cfg);
    plot_polarity_check(results, cfg);
    plot_freq_phase_corrections(results, cfg);
    plot_water_removal(results, cfg);
    plot_preprocessing_step_by_step(results, cfg);

    fprintf('\nPipeline completed successfully for REF scan %d.\n', refScanNum);
end