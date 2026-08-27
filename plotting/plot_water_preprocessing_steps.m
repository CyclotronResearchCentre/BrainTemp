function plot_water_preprocessing_steps(results, cfg)
% PLOT_WATER_PREPROCESSING_STEPS
% Creates a dedicated figure for the water branch (REF).
%
% Panels:
% 1. REF spectrum
% 2. Water region zoom
% 3. Water fit
% 4. Water fit residual
% 5. REF frequency correction
% 6. Summary

    % ---------------------------------------------------------------------
    % Figure and layout
    % ---------------------------------------------------------------------
    fig = figure('Color', 'w', 'Position', [100 100 1400 900]);
    tl = tiledlayout(2,3, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, 'Water branch (REF)', 'FontSize', 16, 'FontWeight', 'bold');

    % Common colors
    colData = [0 0 0];                  % black
    colFit  = [0.85 0.325 0.098];      % orange/red
    colRef  = [0 0.4470 0.7410];       % MATLAB blue
    colRes  = [0 0.4470 0.7410];       % blue residual
    colCtr  = [0 0.4470 0.7410];       % blue center line

    % ---------------------------------------------------------------------
    % 1. REF input / averaged spectrum
    % ---------------------------------------------------------------------
    nexttile;
    plot(results.ref_proc.avg.ppm, real(results.ref_proc.avg.specs), ...
        'Color', colRef, 'LineWidth', 1.2);
    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlabel('ppm');
    ylabel('Real(spec)');
    title('1. REF spectrum');

    % ---------------------------------------------------------------------
    % 2. Water region zoom
    % ---------------------------------------------------------------------
    nexttile;
    idxWater = results.ref_proc.avg.ppm >= min(cfg.waterFitPpmRange) & ...
               results.ref_proc.avg.ppm <= max(cfg.waterFitPpmRange);

    plot(results.ref_proc.avg.ppm(idxWater), real(results.ref_proc.avg.specs(idxWater)), ...
        'Color', colRef, 'LineWidth', 1.2);
    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlabel('ppm');
    ylabel('Real(spec)');
    title('2. Water region zoom');

    % ---------------------------------------------------------------------
    % 3. Water fit
    % ---------------------------------------------------------------------
    nexttile;

    plot(results.waterFit.x, results.waterFit.y, ...
        'Color', colData, 'LineWidth', 1.5, 'DisplayName', 'Data');
    hold on;

    plot(results.waterFit.x, results.waterFit.yhat, ...
        'Color', colFit, 'LineStyle', '--', 'LineWidth', 2, ...
        'DisplayName', 'Lorentzian fit');

    xline(results.waterFit.centerPpm, '--', ...
        'Color', colCtr, 'LineWidth', 1.2, ...
        'Label', sprintf('%.4f ppm', results.waterFit.centerPpm), ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'middle');

    hold off;

    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlabel('ppm');
    ylabel('Real(spec)');
    title(sprintf('3. Water fit (center = %.5f ppm)', results.waterFit.centerPpm));

    % Keep the legend away from the peak
    legend('Location', 'northoutside', ...
        'Orientation', 'horizontal', ...
        'Box', 'off');

    % Optional: center the water fit window nicely
    xlim([min(results.waterFit.x), max(results.waterFit.x)]);

    % ---------------------------------------------------------------------
    % 4. Water fit residual
    % ---------------------------------------------------------------------
    nexttile;

    residual = results.waterFit.y - results.waterFit.yhat;

    plot(results.waterFit.x, residual, ...
        'Color', colRes, 'LineWidth', 1.5);

    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlabel('ppm');
    ylabel('Residual');
    title('4. Water fit residual');
    xlim([min(results.waterFit.x), max(results.waterFit.x)]);

    % ---------------------------------------------------------------------
    % 5. Optional frequency corrections for REF
    % ---------------------------------------------------------------------
    nexttile;
    if isfield(results.ref_proc, 'fs') && ~isempty(results.ref_proc.fs)
        plot(results.ref_proc.fs, '-o', ...
            'Color', colRef, 'LineWidth', 1.2, ...
            'MarkerFaceColor', colRef);
        xlabel('Transient');
        ylabel('Hz');
        title('5. REF frequency correction');
        set(gca, 'FontSize', 11);
    else
        axis off;
        text(0, 0.80, '5. REF frequency correction', ...
            'FontSize', 12, 'FontWeight', 'bold');
        text(0, 0.52, 'No transient-wise frequency correction available', ...
            'FontSize', 11);
    end

    % ---------------------------------------------------------------------
    % 6. Summary
    % ---------------------------------------------------------------------
    nexttile;
    axis off;

    txt = {
        sprintf('REF scan: %d', results.refScanNum)
        sprintf('Water fit center: %.5f ppm', results.waterFit.centerPpm)
        sprintf('Water fit gamma: %.5f', results.waterFit.gamma)
    };

   if isfield(results.waterFit, 'model')
       txt{end+1} = sprintf('Fit model: %s', results.waterFit.model);
   end

    if isfield(results.ref_proc, 'phs') && ~isempty(results.ref_proc.phs)
        txt{end+1} = sprintf('Number of REF transients: %d', numel(results.ref_proc.phs));
    else
        txt{end+1} = 'REF transients: single / already averaged';
    end

    if isfield(results, 'thermo')
        txt{end+1} = sprintf('Delta ppm = %.5f', results.thermo.deltaPPM);
        txt{end+1} = sprintf('Temperature = %.3f °C', results.thermo.temperatureC);
    end

    text(0, 1, txt, ...
        'Units', 'normalized', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 11);
    title('6. Summary');

    % ---------------------------------------------------------------------
    % Save figure
    % ---------------------------------------------------------------------
    figPath = fullfile(cfg.outputFigDir, ...
        sprintf('REF_%d__water_preprocessing_steps.png', results.refScanNum));

    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end
