function plot_freq_phase_corrections(results, cfg)
% PLOT_FREQ_PHASE_CORRECTIONS
% Plots the transient-wise frequency and phase corrections.

    fig = figure('Color', 'w', 'Position', [100 100 1200 500]);

    subplot(1,2,1);
    plot(results.fs, '-o');
    xlabel('Transient');
    ylabel('Hz');
    title('Frequency correction');

    subplot(1,2,2);
    plot(results.phs, '-o');
    xlabel('Transient');
    ylabel('Degrees');
    title('Phase correction');

    figPath = fullfile(cfg.outputFigDir, ...
        sprintf('REF_%d__WSRES_%d_freq_phase.png', results.refScanNum, results.wsresNum));
    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end