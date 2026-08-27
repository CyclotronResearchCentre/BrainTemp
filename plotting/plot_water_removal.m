function plot_water_removal(results, cfg)
% PLOT_WATER_REMOVAL
% Plots the spectrum before and after residual water removal.

    fig = figure('Color', 'w', 'Position', [100 100 1200 800]);

    subplot(2,1,1);
    plot(results.wsres_polcorr.ppm, real(results.wsres_polcorr.specs), 'DisplayName', 'Before water removal');
    hold on;
    plot(results.wsres_water_removed.ppm, real(results.wsres_water_removed.specs), 'DisplayName', 'After water removal');
    hold off;
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Real(spec)');
    title('Residual water removal');
    legend('Location', 'best');

    subplot(2,1,2);
    idx = results.wsres_polcorr.ppm >= min(cfg.waterPpmRange) & ...
          results.wsres_polcorr.ppm <= max(cfg.waterPpmRange);

    plot(results.wsres_polcorr.ppm(idx), real(results.wsres_polcorr.specs(idx)), 'DisplayName', 'Before');
    hold on;
    plot(results.wsres_water_removed.ppm(idx), real(results.wsres_water_removed.specs(idx)), 'DisplayName', 'After');
    hold off;
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Real(spec)');
    title('Residual water region zoom');
    legend('Location', 'best');

    figPath = fullfile(cfg.outputFigDir, ...
        sprintf('REF_%d__WSRES_%d_water_removal.png', results.refScanNum, results.wsresNum));
    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end