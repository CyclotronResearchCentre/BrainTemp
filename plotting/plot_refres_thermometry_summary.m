function plot_refres_thermometry_summary(summaryTable, cfg)
% PLOT_REFRES_THERMOMETRY_SUMMARY
% Plots REF_RES unsuppressed thermometry summary.

    okIdx = summaryTable.status == "ok";
    T = summaryTable(okIdx, :);

    if isempty(T)
        warning('No successful REF_RES runs to plot.');
        return;
    end

    fig = figure('Color', 'w', 'Position', [100 100 1600 1000]);
    tl = tiledlayout(3,2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, 'REF\_RES unsuppressed thermometry summary', ...
        'FontSize', 16, 'FontWeight', 'bold');

    % 1. Temperature
    nexttile;
    plot(T.REFRES_scan, T.temperature_C, 'o', ...
        'LineWidth', 1.5, 'MarkerFaceColor', [0 0.4470 0.7410]);
    xlabel('REF\_RES scan');
    ylabel('Temperature (°C)');
    title('1. Temperature vs scan');
    grid on;
    set(gca, 'FontSize', 11);
    ylim(padded_limits(T.temperature_C));

    % 2. Delta ppm
    nexttile;
    plot(T.REFRES_scan, T.deltaPPM, 'o', ...
        'LineWidth', 1.5, 'MarkerFaceColor', [0 0.4470 0.7410]);
    xlabel('REF\_RES scan');
    ylabel('\Delta ppm');
    title('2. Water–NAA chemical shift');
    grid on;
    set(gca, 'FontSize', 11);
    ylim(padded_limits(T.deltaPPM));

    % 3. Water peak position
    nexttile;
    plot(T.REFRES_scan, T.water_ppm, 'o', ...
        'LineWidth', 1.5, 'MarkerFaceColor', [0 0.4470 0.7410]);
    xlabel('REF\_RES scan');
    ylabel('Water peak position (ppm)');
    title('3. Water peak position');
    grid on;
    set(gca, 'FontSize', 11);
    ylim(padded_limits(T.water_ppm));

    % 4. NAA peak position
    nexttile;
    plot(T.REFRES_scan, T.naa_ppm, 'o', ...
        'LineWidth', 1.5, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
    xlabel('REF\_RES scan');
    ylabel('NAA peak position (ppm)');
    title('4. NAA peak position');
    grid on;
    set(gca, 'FontSize', 11);
    ylim(padded_limits(T.naa_ppm));

    % 5. NAA amplitude
    nexttile;
    plot(T.REFRES_scan, T.naa_amp, 'o', ...
        'LineWidth', 1.5, 'MarkerFaceColor', [0 0.4470 0.7410]);
    xlabel('REF\_RES scan');
    ylabel('NAA amplitude');
    title('5. NAA fitted amplitude');
    grid on;
    set(gca, 'FontSize', 11);
    ylim(padded_limits(T.naa_amp));

    % 6. Summary
    nexttile;
    axis off;

    txt = {};
    txt{end+1} = sprintf('Successful runs: %d / %d', height(T), height(summaryTable));
    txt{end+1} = sprintf('Mean temperature: %.3f °C', mean(T.temperature_C, 'omitnan'));
    txt{end+1} = sprintf('Std temperature: %.3f °C', std(T.temperature_C, 'omitnan'));
    txt{end+1} = sprintf('Mean water ppm: %.5f', mean(T.water_ppm, 'omitnan'));
    txt{end+1} = sprintf('Std water ppm: %.5f', std(T.water_ppm, 'omitnan'));
    txt{end+1} = sprintf('Mean NAA ppm: %.5f', mean(T.naa_ppm, 'omitnan'));
    txt{end+1} = sprintf('Std NAA ppm: %.5f', std(T.naa_ppm, 'omitnan'));
    txt{end+1} = sprintf('Mean deltaPPM: %.5f', mean(T.deltaPPM, 'omitnan'));
    txt{end+1} = sprintf('Std deltaPPM: %.5f', std(T.deltaPPM, 'omitnan'));

    if any(strlength(T.fit_model) > 0)
        txt{end+1} = sprintf('Fit model(s): %s', ...
            strjoin(cellstr(unique(T.fit_model)), ', '));
    end

    text(0, 1, txt, ...
        'Units', 'normalized', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 11);
    title('6. Summary');

    figPath = fullfile(cfg.outputFigDir, ...
        'refres_unsuppressed_thermometry_summary.png');

    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end


function lim = padded_limits(x)
% PADDED_LIMITS
% Returns tight y-limits with padding to show small variations clearly.

    x = x(:);
    x = x(~isnan(x));

    if isempty(x)
        lim = [0 1];
        return;
    end

    xmin = min(x);
    xmax = max(x);

    if xmin == xmax
        pad = max(abs(xmin) * 0.001, 0.001);
    else
        pad = 0.15 * (xmax - xmin);
    end

    lim = [xmin - pad, xmax + pad];
end
