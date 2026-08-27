function plot_thermometry_summary(summaryTable, cfg)
% PLOT_THERMOMETRY_SUMMARY
% Creates a global summary figure across runs.

    okIdx = summaryTable.status == "ok";
    T = summaryTable(okIdx, :);

    if isempty(T)
        warning('No successful runs available for summary plotting.');
        return;
    end

    fig = figure('Color', 'w', 'Position', [100 100 1500 900]);
    tl = tiledlayout(2,2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, 'Thermometry summary across runs', 'FontSize', 16, 'FontWeight', 'bold');

    % ---------------------------------------------------------------------
    % 1. Temperature per REF scan
    % ---------------------------------------------------------------------
    nexttile;
    plot(T.REF_scan, T.temperature_C, '-o', ...
        'LineWidth', 1.5, ...
        'MarkerFaceColor', [0 0.4470 0.7410]);
    xlabel('REF scan');
    ylabel('Temperature (°C)');
    title('1. Temperature by REF scan');
    set(gca, 'FontSize', 11);

    % ---------------------------------------------------------------------
    % 2. Delta ppm per REF scan
    % ---------------------------------------------------------------------
    nexttile;
    plot(T.REF_scan, T.deltaPPM, '-o', ...
        'LineWidth', 1.5, ...
        'MarkerFaceColor', [0 0.4470 0.7410]);
    xlabel('REF scan');
    ylabel('\Delta ppm');
    title('2. Water-NAA shift by REF scan');
    set(gca, 'FontSize', 11);

    % ---------------------------------------------------------------------
    % 3. Water ppm vs NAA ppm
    % ---------------------------------------------------------------------
    nexttile;
    plot(T.REF_scan, T.water_ppm, '-o', ...
        'LineWidth', 1.5, ...
        'MarkerFaceColor', [0 0.4470 0.7410], ...
        'DisplayName', 'Water');
    hold on;
    plot(T.REF_scan, T.naa_ppm, '-s', ...
        'LineWidth', 1.5, ...
        'MarkerFaceColor', [0.8500 0.3250 0.0980], ...
        'DisplayName', 'NAA');
    hold off;
    xlabel('REF scan');
    ylabel('ppm');
    title('3. Peak positions by REF scan');
    legend('Location', 'best');
    set(gca, 'FontSize', 11);

    % ---------------------------------------------------------------------
    % 4. Summary text panel
    % ---------------------------------------------------------------------
    nexttile;
    axis off;

    meanTemp = mean(T.temperature_C, 'omitnan');
    stdTemp  = std(T.temperature_C, 'omitnan');
    meanDelta = mean(T.deltaPPM, 'omitnan');
    stdDelta  = std(T.deltaPPM, 'omitnan');

    nPos = sum(T.naa_amplitude >= 0, 'omitnan');
    nNeg = sum(T.naa_amplitude < 0, 'omitnan');

    txt = {};
    txt{end+1} = sprintf('Successful runs: %d / %d', height(T), height(summaryTable));
    txt{end+1} = sprintf('Mean temperature: %.3f °C', meanTemp);
    txt{end+1} = sprintf('Std temperature: %.3f °C', stdTemp);
    txt{end+1} = sprintf('Mean \\Delta ppm: %.5f', meanDelta);
    txt{end+1} = sprintf('Std \\Delta ppm: %.5f', stdDelta);

    if ~isempty(T.fit_model)
        models = unique(T.fit_model);
        txt{end+1} = sprintf('Fit model(s): %s', strjoin(cellstr(models), ', '));
    end

    txt{end+1} = sprintf('NAA positive fits: %d', nPos);
    txt{end+1} = sprintf('NAA negative fits: %d', nNeg);

    text(0, 1, txt, 'Units', 'normalized', ...
        'VerticalAlignment', 'top', 'FontSize', 11);
    title('4. Summary');

    % ---------------------------------------------------------------------
    % Save
    % ---------------------------------------------------------------------
    figPath = fullfile(cfg.outputFigDir, 'thermometry_summary.png');
    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end