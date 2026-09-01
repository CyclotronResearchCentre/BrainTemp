function run_compare_ws_wsres_ref(refScanNum)
% RUN_COMPARE_WS_WSRES_REF  Overlay REF, WS, and WS_RES for one scan.
%
%   RUN_COMPARE_WS_WSRES_REF(refScanNum) loads the REF, nearest WS, and
%   nearest WS_RES acquisitions for one REF scan number, aligns WS_RES,
%   and plots a normalized overlay of all three (PLOT_OVERLAY_REF_WS_WSRES).
%   A quick sanity-check tool for confirming the three acquisition types
%   line up as expected before running full thermometry.
%
%   Input
%   -----
%   refScanNum : scan number of the REF acquisition
%
%   Example
%   -------
%       run_compare_ws_wsres_ref(39)
%
%   See also: COMPARE_WS_WSRES_REF, PLOT_OVERLAY_REF_WS_WSRES

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