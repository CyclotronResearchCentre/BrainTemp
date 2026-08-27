function plot_transient_stability_sequential(summaryN, cfg, refScanNum, wsresNum)
% PLOT_TRANSIENT_STABILITY_SEQUENTIAL
% Plots temperature convergence as a function of the first N transients.

    fig = figure('Color','w','Position',[100 100 1400 900]);
    tl = tiledlayout(2,2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, 'Temperature stability vs number of included transients', ...
        'FontSize', 16, 'FontWeight', 'bold');

    % Temperature
    nexttile;
    plot(summaryN.N_transients, summaryN.temperature_C, '-o', ...
        'LineWidth', 1.5, 'MarkerFaceColor', [0 0.4470 0.7410]);
    xlabel('Number of first WS\_RES transients included');
    ylabel('Temperature (°C)');
    title('1. Temperature convergence');
    grid on;
    set(gca, 'FontSize', 11);

    % Delta ppm
    nexttile;
    plot(summaryN.N_transients, summaryN.deltaPPM, '-o', ...
        'LineWidth', 1.5, 'MarkerFaceColor', [0 0.4470 0.7410]);
    xlabel('Number of first WS\_RES transients included');
    ylabel('\Delta ppm');
    title('2. Water–NAA shift convergence');
    grid on;
    set(gca, 'FontSize', 11);

    % NAA linewidth
    nexttile;
    plot(summaryN.N_transients, summaryN.naa_gamma, '-o', ...
        'LineWidth', 1.5, 'MarkerFaceColor', [0 0.4470 0.7410]);
    xlabel('Number of first WS\_RES transients included');
    ylabel('NAA gamma');
    title('3. NAA linewidth parameter');
    grid on;
    set(gca, 'FontSize', 11);

    % NAA amplitude
    nexttile;
    plot(summaryN.N_transients, summaryN.naa_amplitude, '-o', ...
        'LineWidth', 1.5, 'MarkerFaceColor', [0 0.4470 0.7410]);
    xlabel('Number of first WS\_RES transients included');
    ylabel('NAA amplitude');
    title('4. NAA fitted amplitude');
    grid on;
    set(gca, 'FontSize', 11);

    figPath = fullfile(cfg.outputFigDir, ...
        sprintf('REF_%d__WSRES_%d_transient_stability_sequential.png', ...
        refScanNum, wsresNum));

    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end