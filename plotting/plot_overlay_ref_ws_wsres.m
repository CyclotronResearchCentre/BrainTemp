function plot_overlay_ref_ws_wsres(results, cfg)
% PLOT_OVERLAY_REF_WS_WSRES
% Creates a normalized overlay of REF, WS, and WS_RES.

    fig = figure('Color', 'w', 'Position', [100 100 1200 800]);

    subplot(2,2,1);
    plot(results.ref_avg.ppm, real(results.ref_avg.specs));
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Real(spec)');
    title(sprintf('REF (%d)', results.refScanNum));

    subplot(2,2,2);
    plot(results.ws_avg.ppm, real(results.ws_avg.specs));
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Real(spec)');
    title(sprintf('WS (%d)', results.wsNum));

    subplot(2,2,3);
    plot(results.wsres_avg.ppm, real(results.wsres_avg.specs));
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Real(spec)');
    title(sprintf('WS_RES (%d)', results.wsresNum));

    subplot(2,2,4);
    hold on;
    plot(results.ref_avg.ppm, normalize_vector(real(results.ref_avg.specs)), 'DisplayName', 'REF');
    plot(results.ws_avg.ppm, normalize_vector(real(results.ws_avg.specs)), 'DisplayName', 'WS');
    plot(results.wsres_avg.ppm, normalize_vector(real(results.wsres_avg.specs)), 'DisplayName', 'WS_RES');
    hold off;
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Normalized amplitude');
    title('Normalized overlay');
    legend('Location', 'best');

    figPath = fullfile(cfg.outputFigDir, ...
        sprintf('REF_%d__WS_%d__WSRES_%d_overlay.png', ...
        results.refScanNum, results.wsNum, results.wsresNum));
    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end