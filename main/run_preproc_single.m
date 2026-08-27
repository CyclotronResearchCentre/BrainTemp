function run_preproc_single(refScanNum)
% RUN_PREPROC_SINGLE
% Main entry point for running the preprocessing pipeline on one REF scan.

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