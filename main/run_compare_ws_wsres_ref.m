function run_compare_ws_wsres_ref(refScanNum)
% RUN_COMPARE_WS_WSRES_REF
% Main entry point for comparing REF, WS, and WS_RES for one REF scan.
%
% Example:
%   run_compare_ws_wsres_ref(39)

    cfg = get_default_config();

    addpath(genpath(cfg.ospreyPath));
    rehash;

    ensure_dir_exists(cfg.outputDir);
    ensure_dir_exists(cfg.outputMatDir);
    ensure_dir_exists(cfg.outputFigDir);

    results = compare_ws_wsres_ref(refScanNum, cfg);

    plot_overlay_ref_ws_wsres(results, cfg);

    fprintf('\nComparison completed successfully for REF scan %d.\n', refScanNum);
end