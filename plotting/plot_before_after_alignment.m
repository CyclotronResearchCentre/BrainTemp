function plot_before_after_alignment(results, cfg)
% PLOT_BEFORE_AFTER_ALIGNMENT
% Plots the spectrum before and after alignment+averaging.

    fig = figure('Color', 'w', 'Position', [100 100 1200 700]);

    subplot(2,1,1);
    plot(results.wsres_avg_before.ppm, real(results.wsres_avg_before.specs));
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Real(spec)');
    title('Before alignment');

    subplot(2,1,2);
    plot(results.wsres_avg_after.ppm, real(results.wsres_avg_after.specs));
    set(gca, 'XDir', 'reverse');
    xlabel('ppm');
    ylabel('Real(spec)');
    title('After alignment + averaging');

    figPath = fullfile(cfg.outputFigDir, ...
        sprintf('REF_%d__WSRES_%d_before_after.png', results.refScanNum, results.wsresNum));
    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end