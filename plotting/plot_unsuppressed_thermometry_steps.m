function plot_unsuppressed_thermometry_steps(results, cfg)
% PLOT_UNSUPPRESSED_THERMOMETRY_STEPS
% QC figure for unsuppressed MRS thermometry.

    fig = figure('Color','w','Position',[100 100 1500 900]);
    tl = tiledlayout(2,3,'TileSpacing','compact','Padding','compact');

    title(tl, 'Unsuppressed MRS thermometry', ...
        'FontSize',16,'FontWeight','bold');

    colSpec = [0 0.4470 0.7410];
    colFit  = [0.8500 0.3250 0.0980];

    % ---------------------------------------------------------------------
    % 1. Before alignment / averaging
    % ---------------------------------------------------------------------
    nexttile;

    plot(results.proc.avg_before.ppm, real(results.proc.avg_before.specs), ...
        'Color', colSpec, 'LineWidth', 1.2);

    set(gca,'XDir','reverse','FontSize',11,'YAxisLocation','left');
    ax = gca;
    ax.YAxis.ExponentMode = 'auto';

    xlim([0 7]);
    xlabel('ppm');
    ylabel('Real(spec)');
    title('1. Before alignment / averaging');
    grid on;

    % ---------------------------------------------------------------------
    % 2. After alignment + averaging
    % ---------------------------------------------------------------------
    nexttile;

    plot(results.proc.avg_after.ppm, real(results.proc.avg_after.specs), ...
        'Color', colSpec, 'LineWidth', 1.2);

    set(gca,'XDir','reverse','FontSize',11,'YAxisLocation','left');
    ax = gca;
    ax.YAxis.ExponentMode = 'auto';

    xlim([0 7]);
    xlabel('ppm');
    ylabel('Real(spec)');
    title('2. After alignment + averaging');
    grid on;

    % ---------------------------------------------------------------------
    % 3. Water fit
    % ---------------------------------------------------------------------
    nexttile;

    hData = plot(results.waterFit.x, results.waterFit.y, ...
        'Color','k','LineWidth',1.5,'DisplayName','Data');
    hold on;

    hFit = plot(results.waterFit.x, results.waterFit.yhat, ...
        'Color', colFit, ...
        'LineStyle','--','LineWidth',2,'DisplayName','Fit');

    hCenter = xline(results.waterFit.centerPpm,'--b', ...
        'LineWidth',1.2, ...
        'Label',sprintf('%.4f ppm',results.waterFit.centerPpm), ...
        'LabelOrientation','aligned');

    hCenter.Annotation.LegendInformation.IconDisplayStyle = 'off';

    hold off;

    set(gca,'XDir','reverse','FontSize',11,'YAxisLocation','left');
    ax = gca;
    ax.YAxis.ExponentMode = 'auto';

    xlabel('ppm');
    ylabel('Real(spec)');
    title(sprintf('3. Water fit | center = %.5f ppm', ...
        results.waterFit.centerPpm));
    grid on;

    legend([hData hFit], {'Data','Fit'}, ...
        'Location','northoutside', ...
        'Orientation','horizontal', ...
        'Box','off');

    % ---------------------------------------------------------------------
    % 4. NAA region
    % ---------------------------------------------------------------------
    nexttile;

    idxNAA = results.proc.avg_after.ppm >= min(cfg.naaFitPpmRange) & ...
             results.proc.avg_after.ppm <= max(cfg.naaFitPpmRange);

    plot(results.proc.avg_after.ppm(idxNAA), ...
         real(results.proc.avg_after.specs(idxNAA)), ...
         'Color', colSpec, 'LineWidth',1.2);

    set(gca,'XDir','reverse','FontSize',11,'YAxisLocation','left');
    ax = gca;
    ax.YAxis.ExponentMode = 'auto';

    xlabel('ppm');
    ylabel('Real(spec)');
    title('4. NAA region');
    grid on;

    % ---------------------------------------------------------------------
    % 5. NAA fit
    % ---------------------------------------------------------------------
    nexttile;

    hData = plot(results.naaFit.x, results.naaFit.y, ...
        'Color','k','LineWidth',1.5,'DisplayName','Data');
    hold on;

    hFit = plot(results.naaFit.x, results.naaFit.yhat, ...
        'Color', colFit, ...
        'LineStyle','--','LineWidth',2,'DisplayName','Fit');

    hCenter = xline(results.naaFit.centerPpm,'--b', ...
        'LineWidth',1.2, ...
        'Label',sprintf('%.4f ppm',results.naaFit.centerPpm), ...
        'LabelOrientation','aligned');

    hCenter.Annotation.LegendInformation.IconDisplayStyle = 'off';

    hold off;

    set(gca,'XDir','reverse','FontSize',11,'YAxisLocation','left');
    ax = gca;
    ax.YAxis.ExponentMode = 'auto';

    xlabel('ppm');
    ylabel('Real(spec)');
    title(sprintf('5. NAA fit | center = %.5f ppm', ...
        results.naaFit.centerPpm));
    grid on;

    legend([hData hFit], {'Data','Fit'}, ...
        'Location','northoutside', ...
        'Orientation','horizontal', ...
        'Box','off');

    % ---------------------------------------------------------------------
    % 6. Summary
    % ---------------------------------------------------------------------
    nexttile;
    axis off;
    
    waterExp = get_signal_exponent(results.waterFit.y);
    naaExp   = get_signal_exponent(results.naaFit.y);

    txt = {};
    txt{end+1} = '';
    txt{end+1} = sprintf('Water ppm = %.5f', results.waterFit.centerPpm);
    txt{end+1} = sprintf('NAA ppm = %.5f', results.naaFit.centerPpm);
    txt{end+1} = sprintf('Delta ppm = %.5f', results.thermo.deltaPPM);
    txt{end+1} = sprintf('Temperature = %.3f °C', results.thermo.temperatureC);

    txt{end+1} = '';
    txt{end+1} = 'Displayed signal scales:';
    txt{end+1} = sprintf('Water fit panel: x10^%d', waterExp);
    txt{end+1} = sprintf('NAA fit panel: x10^%d', naaExp);


    if isfield(results.waterFit, 'gamma')
        txt{end+1} = sprintf('Water gamma = %.5f ppm', results.waterFit.gamma);
    end

    if isfield(results.naaFit, 'gamma')
        txt{end+1} = sprintf('NAA gamma = %.5f ppm', results.naaFit.gamma);
    end

    if isfield(results.naaFit, 'sigma')
        txt{end+1} = sprintf('NAA sigma = %.5f ppm', results.naaFit.sigma);
    end

    if isfield(results.naaFit, 'eta')
        txt{end+1} = sprintf('NAA pseudo-Voigt eta = %.3f', results.naaFit.eta);
    end

    if isfield(results.naaFit, 'model')
        txt{end+1} = sprintf('Fit model = %s', results.naaFit.model);
    end

    txt{end+1} = '';

    if isfield(results.proc, 'fs') && ~isempty(results.proc.fs)
        txt{end+1} = sprintf('Mean |fs| = %.3f Hz', mean(abs(results.proc.fs)));
    end

    if isfield(results.proc, 'phs') && ~isempty(results.proc.phs)
        txt{end+1} = sprintf('Mean |phs| = %.3f deg', mean(abs(results.proc.phs)));
    end

    text(0,1,txt, ...
        'Units','normalized', ...
        'VerticalAlignment','top', ...
        'FontSize',9);

    title('6. Summary');

    % ---------------------------------------------------------------------
    % Save figure
    % ---------------------------------------------------------------------
    [~, nameOnly, ~] = fileparts(results.dataPath);
    nameOnly = strrep(nameOnly, '.nii', '');

    figPath = fullfile(cfg.outputFigDir, ...
        [nameOnly '_unsuppressed_thermometry.png']);

    exportgraphics(fig, figPath, 'Resolution',150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end

function expVal = get_signal_exponent(y)
% GET_SIGNAL_EXPONENT
% Estimate the base-10 exponent of a signal scale.

    y = y(:);
    y = y(~isnan(y) & ~isinf(y));

    if isempty(y) || max(abs(y)) == 0
        expVal = 0;
        return;
    end

    expVal = floor(log10(max(abs(y))));
end
