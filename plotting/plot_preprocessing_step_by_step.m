function plot_preprocessing_step_by_step(results, cfg)
% PLOT_PREPROCESSING_STEP_BY_STEP
% Displays preprocessing in two panels:
%   - REF (water reference)
%   - WS_RES (metabolite processing)

    fig = figure('Color', 'w', 'Position', [100 100 1600 900]);

    % Use tiled layout
    t = tiledlayout(2,1, 'TileSpacing', 'compact', 'Padding', 'compact');

    % ============================================================
    % 🔵 PANEL 1: REF (WATER)
    % ============================================================
    nexttile;
    t1 = tiledlayout(1,3, 'TileSpacing', 'compact', 'Padding', 'compact');

    title(t1, 'REF (Water Reference)', 'FontSize', 14, 'FontWeight', 'bold');

    % --- Full REF spectrum ---
    nexttile;
    plot(results.ref_proc.avg.ppm, real(results.ref_proc.avg.specs));
    set(gca, 'XDir', 'reverse');
    xlabel('ppm'); ylabel('Real(spec)');
    title('Full spectrum');

    % --- Water region zoom ---
    nexttile;
    idxWater = results.ref_proc.avg.ppm >= min(cfg.waterFitPpmRange) & ...
               results.ref_proc.avg.ppm <= max(cfg.waterFitPpmRange);

    plot(results.ref_proc.avg.ppm(idxWater), real(results.ref_proc.avg.specs(idxWater)));
    set(gca, 'XDir', 'reverse');
    xlabel('ppm'); ylabel('Real(spec)');
    title('Water region');

    % --- Water fit ---
    nexttile;
    plot(results.waterFit.x, results.waterFit.y, 'DisplayName', 'Data');
    hold on;
    plot(results.waterFit.x, results.waterFit.yhat, 'DisplayName', 'Fit');
    hold off;
    set(gca, 'XDir', 'reverse');
    xlabel('ppm'); ylabel('Real(spec)');
    title(sprintf('Water fit = %.5f ppm', results.waterFit.centerPpm));
    legend('Location','best');

    % ============================================================
    % 🔴 PANEL 2: WS_RES (METABOLITES)
    % ============================================================
    nexttile;
    t2 = tiledlayout(2,3, 'TileSpacing', 'compact', 'Padding', 'compact');

    title(t2, 'WS_RES (Metabolite Processing)', 'FontSize', 14, 'FontWeight', 'bold');

    % --- Before alignment ---
    nexttile;
    plot(results.wsres_avg_before.ppm, real(results.wsres_avg_before.specs));
    set(gca, 'XDir', 'reverse');
    xlabel('ppm'); ylabel('Real(spec)');
    title('Before alignment');

    % --- After alignment ---
    nexttile;
    plot(results.wsres_avg_after.ppm, real(results.wsres_avg_after.specs));
    set(gca, 'XDir', 'reverse');
    xlabel('ppm'); ylabel('Real(spec)');
    title('After alignment + averaging');

    % --- After polarity ---
    nexttile;
    plot(results.wsres_polcorr.ppm, real(results.wsres_polcorr.specs));
    set(gca, 'XDir', 'reverse');
    xlabel('ppm'); ylabel('Real(spec)');
    title(sprintf('After polarity (flip=%d)', results.flipped));

    % --- Water removal zoom ---
    nexttile;
    idxWater2 = results.wsres_polcorr.ppm >= min(cfg.waterPpmRange) & ...
                results.wsres_polcorr.ppm <= max(cfg.waterPpmRange);

    plot(results.wsres_polcorr.ppm(idxWater2), real(results.wsres_polcorr.specs(idxWater2)), 'DisplayName','Before');
    hold on;
    plot(results.wsres_water_removed.ppm(idxWater2), real(results.wsres_water_removed.specs(idxWater2)), 'DisplayName','After');
    hold off;
    set(gca, 'XDir', 'reverse');
    xlabel('ppm'); ylabel('Real(spec)');
    title('Water removal');
    legend;

    % --- NAA region ---
    nexttile;
    idxNAA = results.wsres_water_removed.ppm >= min(cfg.naaFitPpmRange) & ...
             results.wsres_water_removed.ppm <= max(cfg.naaFitPpmRange);

    plot(results.wsres_water_removed.ppm(idxNAA), real(results.wsres_water_removed.specs(idxNAA)));
    set(gca, 'XDir', 'reverse');
    xlabel('ppm'); ylabel('Real(spec)');
    title(sprintf('NAA region (%.5f ppm)', results.naaFit.centerPpm));

    % --- Summary ---
    nexttile;
    axis off;

    txt = {
        sprintf('Water ppm: %.5f', results.waterFit.centerPpm)
        sprintf('NAA ppm: %.5f', results.naaFit.centerPpm)
        sprintf('\\Delta ppm: %.5f', results.thermo.deltaPPM)
        sprintf('Temperature: %.2f °C', results.thermo.temperatureC)
    };

    text(0,1,txt,'VerticalAlignment','top','FontSize',11);

    % ============================================================
    % Save figure
    % ============================================================
    figPath = fullfile(cfg.outputFigDir, ...
        sprintf('REF_%d__WSRES_%d_preprocessing_panels.png', ...
        results.refScanNum, results.wsresNum));

    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end
