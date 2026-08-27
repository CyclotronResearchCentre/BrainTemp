function plot_refres_transient_stability(summaryN, cfg, refresScanNum)
% PLOT_REFRES_TRANSIENT_STABILITY
% Plots unsuppressed REF_RES thermometry stability vs number of transients.

    fig = figure('Color','w','Position',[100 100 1500 900]);
    tl = tiledlayout(2,3,'TileSpacing','compact','Padding','compact');

    title(tl, sprintf('REF\\_RES %d: thermometry stability vs number of transients', refresScanNum), ...
        'FontSize',16,'FontWeight','bold');

    % 1. Temperature
    nexttile;
    plot(summaryN.N_transients, summaryN.temperature_C, 'o', ...
        'MarkerSize',8,'LineWidth',1.5);
    xlabel('Number of first transients included');
    ylabel('Temperature (°C)');
    title('1. Temperature');
    grid on;
    ylim(padded_limits(summaryN.temperature_C));

    % 2. Delta ppm
    nexttile;
    plot(summaryN.N_transients, summaryN.deltaPPM, 'o', ...
        'MarkerSize',8,'LineWidth',1.5);
    xlabel('Number of first transients included');
    ylabel('\Delta ppm');
    title('2. Water–NAA shift');
    grid on;
    ylim(padded_limits(summaryN.deltaPPM));

    % 3. Water peak position
    nexttile;
    plot(summaryN.N_transients, summaryN.water_ppm, 'o', ...
        'MarkerSize',8,'LineWidth',1.5);
    xlabel('Number of first transients included');
    ylabel('Water ppm');
    title('3. Water peak position');
    grid on;
    ylim(padded_limits(summaryN.water_ppm));

    % 4. NAA peak position
    nexttile;
    plot(summaryN.N_transients, summaryN.naa_ppm, 'o', ...
        'MarkerSize',8,'LineWidth',1.5);
    xlabel('Number of first transients included');
    ylabel('NAA ppm');
    title('4. NAA peak position');
    grid on;
    ylim(padded_limits(summaryN.naa_ppm));

    % 5. Linewidths
    nexttile;
    plot(summaryN.N_transients, summaryN.water_gamma, 'o', ...
        'MarkerSize',8,'LineWidth',1.5,'DisplayName','Water gamma');
    hold on;
    plot(summaryN.N_transients, summaryN.naa_gamma, 's', ...
        'MarkerSize',8,'LineWidth',1.5,'DisplayName','NAA gamma');
    hold off;
    xlabel('Number of first transients included');
    ylabel('Gamma (ppm)');
    title('5. Linewidth parameters');
    legend('Location','best');
    grid on;

    % 6. Summary
    nexttile;
    axis off;

    txt = {};
    txt{end+1} = sprintf('REF_RES scan: %d', refresScanNum);
    txt{end+1} = sprintf('N tested: %s', mat2str(summaryN.N_transients'));
    txt{end+1} = '';
    txt{end+1} = sprintf('Final T = %.3f °C', summaryN.temperature_C(end));
    txt{end+1} = sprintf('Final deltaPPM = %.5f', summaryN.deltaPPM(end));
    txt{end+1} = sprintf('Final water ppm = %.5f', summaryN.water_ppm(end));
    txt{end+1} = sprintf('Final NAA ppm = %.5f', summaryN.naa_ppm(end));
    txt{end+1} = '';
    txt{end+1} = sprintf('Temperature range = %.3f °C', ...
        max(summaryN.temperature_C) - min(summaryN.temperature_C));

    if height(summaryN) >= 2
        txt{end+1} = sprintf('Last-step change = %.3f °C', ...
            summaryN.temperature_C(end) - summaryN.temperature_C(end-1));
    end

    if any(strlength(summaryN.fit_model) > 0)
        txt{end+1} = sprintf('Fit model(s): %s', ...
            strjoin(cellstr(unique(summaryN.fit_model)), ', '));
    end

    text(0,1,txt,'Units','normalized', ...
        'VerticalAlignment','top','FontSize',11);

    title('6. Summary');

    figPath = fullfile(cfg.outputFigDir, ...
        sprintf('REFRES_%d_unsuppressed_transient_stability.png', refresScanNum));

    exportgraphics(fig, figPath, 'Resolution',150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end


function lim = padded_limits(x)

    x = x(:);
    x = x(~isnan(x) & ~isinf(x));

    if isempty(x)
        lim = [0 1];
        return;
    end

    xmin = min(x);
    xmax = max(x);

    if xmin == xmax
        pad = max(abs(xmin)*0.001, 0.001);
    else
        pad = 0.15 * (xmax - xmin);
    end

    lim = [xmin - pad, xmax + pad];
end