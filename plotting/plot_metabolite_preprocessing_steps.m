function plot_metabolite_preprocessing_steps(results, cfg)
% PLOT_METABOLITE_PREPROCESSING_STEPS
% Creates a dedicated figure for the metabolite branch (WS_RES).
%
% Panels:
% 1. Before alignment
% 2. After alignment + averaging
% 3. After ECC
% 4. After polarity correction
% 5. Water removal zoom
% 6. NAA region zoom
% 7. NAA fit
% 8. NAA fit residual
% 9. Summary

    % ---------------------------------------------------------------------
    % Figure and layout
    % ---------------------------------------------------------------------
    fig = figure('Color', 'w', 'Position', [100 100 1600 1100]);
    tl = tiledlayout(3,3, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, 'Metabolite branch (WS_RES)', 'FontSize', 16, 'FontWeight', 'bold');

    % Common colors (harmonized with water figure)
    colSpec   = [0 0.4470 0.7410];      % MATLAB blue
    colAfter  = [0.8500 0.3250 0.0980]; % orange
    colData   = [0 0 0];                % black
    colFit    = [0.8500 0.3250 0.0980]; % orange fit
    colResid  = [0 0.4470 0.7410];      % blue residual
    colCenter = [0 0.4470 0.7410];      % blue center line

    % ---------------------------------------------------------------------
    % 1. Before alignment
    % ---------------------------------------------------------------------
    nexttile;
    plot(results.wsres_avg_before.ppm, real(results.wsres_avg_before.specs), ...
        'Color', colSpec, 'LineWidth', 1.2);
    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlim([1 6]);
    xlabel('ppm');
    ylabel('Real(spec)');
    title('1. Before alignment');

    % ---------------------------------------------------------------------
    % 2. After alignment + averaging
    % ---------------------------------------------------------------------
    nexttile;
    plot(results.wsres_avg_after.ppm, real(results.wsres_avg_after.specs), ...
        'Color', colSpec, 'LineWidth', 1.2);
    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlim([1 6]);
    xlabel('ppm');
    ylabel('Real(spec)');
    title('2. After alignment + averaging');

    % ---------------------------------------------------------------------
    % 3. After ECC
    % ---------------------------------------------------------------------
    nexttile;
    plot(results.wsres_ecc.ppm, real(results.wsres_ecc.specs), ...
        'Color', colSpec, 'LineWidth', 1.2);
    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlim([1 6]);
    xlabel('ppm');
    ylabel('Real(spec)');
    title('3. After ECC');

    % ---------------------------------------------------------------------
    % 4. After polarity correction
    % ---------------------------------------------------------------------
    nexttile;
    plot(results.wsres_polcorr.ppm, real(results.wsres_polcorr.specs), ...
        'Color', colSpec, 'LineWidth', 1.2);
    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlim([1 6]);
    xlabel('ppm');
    ylabel('Real(spec)');
    title(sprintf('4. After polarity correction (flip=%d)', results.flipped));

    % ---------------------------------------------------------------------
    % 5. Water region before/after water removal
    % ---------------------------------------------------------------------
    nexttile;
    idxWater = results.wsres_polcorr.ppm >= min(cfg.waterPpmRange) & ...
               results.wsres_polcorr.ppm <= max(cfg.waterPpmRange);

    plot(results.wsres_polcorr.ppm(idxWater), real(results.wsres_polcorr.specs(idxWater)), ...
        'Color', colSpec, 'LineWidth', 1.2, 'DisplayName', 'Before');
    hold on;
    plot(results.wsres_water_removed.ppm(idxWater), real(results.wsres_water_removed.specs(idxWater)), ...
        'Color', colAfter, 'LineWidth', 1.2, 'DisplayName', 'After');
    hold off;

    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlabel('ppm');
    ylabel('Real(spec)');
    title('5. Water removal zoom');

    legend('Location', 'northoutside', ...
        'Orientation', 'horizontal', ...
        'Box', 'off');

    % ---------------------------------------------------------------------
    % 6. NAA region zoom
    % ---------------------------------------------------------------------
    nexttile;
    idxNAA = results.wsres_water_removed.ppm >= min(cfg.naaFitPpmRange) & ...
             results.wsres_water_removed.ppm <= max(cfg.naaFitPpmRange);

    plot(results.wsres_water_removed.ppm(idxNAA), real(results.wsres_water_removed.specs(idxNAA)), ...
        'Color', colSpec, 'LineWidth', 1.2);
    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlabel('ppm');
    ylabel('Real(spec)');
    title('6. NAA region zoom');

    % ---------------------------------------------------------------------
    % 7. NAA fit
    % ---------------------------------------------------------------------
    nexttile;
    plot(results.naaFit.x, results.naaFit.y, ...
        'Color', colData, 'LineWidth', 1.5, 'DisplayName', 'Data');
    hold on;

    plot(results.naaFit.x, results.naaFit.yhat, ...
        'Color', colFit, 'LineStyle', '--', 'LineWidth', 2, ...
        'DisplayName', 'Lorentzian fit');

    xline(results.naaFit.centerPpm, '--', ...
        'Color', colCenter, 'LineWidth', 1.2, ...
        'Label', sprintf('%.4f ppm', results.naaFit.centerPpm), ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'middle');

    hold off;

    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlim([results.naaFit.centerPpm - 0.15, results.naaFit.centerPpm + 0.15]);
    ylim([min(results.naaFit.y)*1.2, max(results.naaFit.y)*1.2]);
    xlabel('ppm');
    ylabel('Real(spec)');
    title(sprintf('7. NAA fit (center = %.5f ppm)', results.naaFit.centerPpm));

    % Keep legend away from the peak
    legend('Location', 'northoutside', ...
        'Orientation', 'horizontal', ...
        'Box', 'off');

    % ---------------------------------------------------------------------
    % 8. NAA fit residual
    % ---------------------------------------------------------------------
    nexttile;
    residual = results.naaFit.y - results.naaFit.yhat;

    plot(results.naaFit.x, residual, ...
        'Color', colResid, 'LineWidth', 1.5);

    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlim([results.naaFit.centerPpm - 0.15, results.naaFit.centerPpm + 0.15]);
    xlabel('ppm');
    ylabel('Residual');
    title('8. NAA fit residual');

    % ---------------------------------------------------------------------
    % 9. Summary
    % ---------------------------------------------------------------------
    nexttile;
    axis off;

    txt = {
        sprintf('WS_RES scan: %d', results.wsresNum)
        sprintf('NAA fit center: %.5f ppm', results.naaFit.centerPpm)
        sprintf('NAA fit gamma: %.5f', results.naaFit.gamma)
        sprintf('Delta ppm = %.5f', results.thermo.deltaPPM)
        sprintf('Temperature = %.3f °C', results.thermo.temperatureC)
    };

    % Add amplitude + polarity
    if isfield(results.naaFit, 'A')
       txt{end+1} = sprintf('NAA amplitude: %.5f', results.naaFit.A);

	    if results.naaFit.A >= 0
		txt{end+1} = 'NAA fit polarity: positive';
	    else
		txt{end+1} = 'NAA fit polarity: negative';
	    end
	end
    if isfield(results.naaFit, 'model')
    	txt{end+1} = sprintf('Fit model: %s', results.naaFit.model);
    end
    
    if isfield(results, 'naaQC_before')
        txt{end+1} = sprintf('NAA sign before: %s', results.naaQC_before.signLabel);
    end
    if isfield(results, 'naaQC_afterECC')
        txt{end+1} = sprintf('NAA sign after ECC: %s', results.naaQC_afterECC.signLabel);
    end
    if isfield(results, 'naaQC_afterWater')
        txt{end+1} = sprintf('NAA sign after water removal: %s', results.naaQC_afterWater.signLabel);
    end

    text(0, 1, txt, ...
        'Units', 'normalized', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 11);
    title('9. Summary');

    % ---------------------------------------------------------------------
    % Save figure
    % ---------------------------------------------------------------------
    figPath = fullfile(cfg.outputFigDir, ...
        sprintf('REF_%d__WSRES_%d__metabolite_preprocessing_steps.png', ...
        results.refScanNum, results.wsresNum));

    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end
