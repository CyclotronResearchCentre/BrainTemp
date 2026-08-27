function plot_thermometry_fit_summary(results, cfg)
% PLOT_THERMOMETRY_FIT_SUMMARY
% Generates a summary figure showing water and NAA fits.

    fig = figure('Color', 'w', 'Position', [100 100 1200 800]);

    % Water fit
    subplot(2,2,1);
    plot(results.waterFit.x, results.waterFit.y, 'DisplayName', 'Data');
    hold on;
    plot(results.waterFit.x, results.waterFit.yhat, 'DisplayName', 'Lorentzian fit');
    hold off;
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Real(spec)');
    title(sprintf('Water fit | center = %.5f ppm', results.waterFit.centerPpm));
    legend('Location', 'best');

    subplot(2,2,2);
    plot(results.waterFit.x, results.waterFit.residual);
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Residual');
    title('Water fit residual');

    % NAA fit
    subplot(2,2,3);
    plot(results.naaFit.x, results.naaFit.y, 'DisplayName', 'Data');
    hold on;
    plot(results.naaFit.x, results.naaFit.yhat, 'DisplayName', 'Lorentzian fit');
    hold off;
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Real(spec)');
    title(sprintf('NAA fit | center = %.5f ppm', results.naaFit.centerPpm));
    legend('Location', 'best');

    subplot(2,2,4);
    plot(results.naaFit.x, results.naaFit.residual);
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Residual');
    title(sprintf('\\Delta = %.5f ppm | T = %.3f °C', ...
        results.thermo.deltaPPM, results.thermo.temperatureC));

    figPath = fullfile(cfg.outputFigDir, ...
        sprintf('REF_%d__WSRES_%d_thermometry_fit.png', ...
        results.refScanNum, results.wsresNum));
    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end
