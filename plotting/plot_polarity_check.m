function plot_polarity_check(results, cfg)
% PLOT_POLARITY_CHECK
% Shows the spectrum before and after polarity correction, with a zoom in
% the residual water region.

    fig = figure('Color', 'w', 'Position', [100 100 1200 800]);

    subplot(2,1,1);
    plot(results.wsres_avg_after.ppm, real(results.wsres_avg_after.specs), 'DisplayName', 'Before polarity correction');
    hold on;
    plot(results.wsres_polcorr.ppm, real(results.wsres_polcorr.specs), 'DisplayName', 'After polarity correction');
    hold off;
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Real(spec)');
    title(sprintf('Polarity correction (flipped = %d)', results.flipped));
    legend('Location', 'best');

    subplot(2,1,2);
    idx = results.wsres_polcorr.ppm >= min(cfg.waterPpmRange) & ...
          results.wsres_polcorr.ppm <= max(cfg.waterPpmRange);

    plot(results.wsres_avg_after.ppm(idx), real(results.wsres_avg_after.specs(idx)), 'DisplayName', 'Before');
    hold on;
    plot(results.wsres_polcorr.ppm(idx), real(results.wsres_polcorr.specs(idx)), 'DisplayName', 'After');
    hold off;
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Real(spec)');
    title('Residual water region zoom');
    legend('Location', 'best');

    figPath = fullfile(cfg.outputFigDir, ...
        sprintf('REF_%d__WSRES_%d_polarity.png', results.refScanNum, results.wsresNum));
    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end