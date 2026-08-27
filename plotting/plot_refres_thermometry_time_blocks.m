function fig = plot_refres_thermometry_time_blocks(summaryT, outDir, scanNum, blockSize, TR)
%PLOT_REFRES_THERMOMETRY_TIME_BLOCKS
% Plot REF_RES dynamic thermometry results in one 2x2 figure.
%
% Panels:
%   1) Water peak vs time
%   2) NAA peak vs time
%   3) Delta ppm vs time
%   4) Temperature vs time, if available
%
% Usage:
%   fig = plot_refres_thermometry_time_blocks(summaryT, outDir, scanNum, blockSize);

    if nargin < 4
        error('Usage: fig = plot_refres_thermometry_time_blocks(summaryT, outDir, scanNum, blockSize)');
    end

    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    fig = figure('Color','w', 'Position',[100 100 1300 900]);

    %% 1) Water peak
    subplot(2,2,1);
    plot(summaryT.timeMin, summaryT.waterPPM, '-o', ...
        'LineWidth', 1.5, ...
        'MarkerSize', 5);
    hold on;

    mu = mean(summaryT.waterPPM, 'omitnan');
    sd = std(summaryT.waterPPM, 'omitnan');

    yline(mu, '--', sprintf('Mean = %.6f ppm', mu), ...
        'LabelHorizontalAlignment', 'left');

    xlabel('Time (min)');
    ylabel('Water peak (ppm)');
    title(sprintf('Water peak (SD = %.6f ppm)', sd));
    grid on;
    box on;

    %% 2) NAA peak
    subplot(2,2,2);
    plot(summaryT.timeMin, summaryT.naaPPM, '-o', ...
        'LineWidth', 1.5, ...
        'MarkerSize', 5);
    hold on;

    mu = mean(summaryT.naaPPM, 'omitnan');
    sd = std(summaryT.naaPPM, 'omitnan');

    yline(mu, '--', sprintf('Mean = %.6f ppm', mu), ...
        'LabelHorizontalAlignment', 'left');

    xlabel('Time (min)');
    ylabel('NAA peak (ppm)');
    title(sprintf('NAA peak (SD = %.6f ppm)', sd));
    grid on;
    box on;

    %% 3) Delta ppm
    subplot(2,2,3);
    plot(summaryT.timeMin, summaryT.deltaPPM, '-o', ...
        'LineWidth', 1.5, ...
        'MarkerSize', 5);
    hold on;

    mu = mean(summaryT.deltaPPM, 'omitnan');
    sd = std(summaryT.deltaPPM, 'omitnan');

    yline(mu, '--', sprintf('Mean = %.6f ppm', mu), ...
        'LabelHorizontalAlignment', 'left');

    xlabel('Time (min)');
    ylabel('\Delta\delta = H_2O - NAA (ppm)');
    title(sprintf('\\Delta ppm\nMean = %.6f | SD = %.6f ppm', mu, sd));
    grid on;
    box on;

    %% 4) Temperature
    subplot(2,2,4);

    if ismember('tempC', summaryT.Properties.VariableNames) && any(~isnan(summaryT.tempC))

        plot(summaryT.timeMin, summaryT.tempC, '-o', ...
            'LineWidth', 1.5, ...
            'MarkerSize', 5);
        hold on;

        mu = mean(summaryT.tempC, 'omitnan');
        sd = std(summaryT.tempC, 'omitnan');

        yline(mu, '--', sprintf('Mean = %.2f °C', mu), ...
            'LabelHorizontalAlignment', 'left');

        ylabel('Temperature (°C)');
        title(sprintf('Temperature (SD = %.3f °C)', sd));

    else

        plot(summaryT.timeMin, nan(size(summaryT.timeMin)), '-o');
        text(0.5, 0.5, ...
            'No temperature calibration available', ...
            'Units', 'normalized', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 12);

        ylabel('Temperature (°C)');
        title('Temperature');

    end

    xlabel('Time (min)');
    grid on;
    box on;

    %% Main title
    sgtitle(sprintf( ...
        ['REF\\_RES %d | TR = %.2f s | Block = %d transients' ...
         ' | Resolution = %.2f s'], ...
         scanNum, TR, blockSize, blockSize*TR), ...
        'FontWeight','bold');

    %% Save
    outPng = fullfile(outDir, ...
        sprintf('REFRES_%d_unsuppressed_time_blocks_%dtransients.png', ...
        scanNum, blockSize));

    exportgraphics(fig, outPng, 'Resolution', 300);

    fprintf('Saved figure:\n%s\n', outPng);
end
