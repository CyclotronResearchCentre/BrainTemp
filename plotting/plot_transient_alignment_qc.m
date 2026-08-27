function plot_transient_alignment_qc(results, cfg)
% PLOT_TRANSIENT_ALIGNMENT_QC
% Visual QC of transient alignment:
%   1) all transients before alignment
%   2) all transients after alignment
%   3) frequency correction
%   4) phase correction

    fig = figure('Color', 'w', 'Position', [100 100 1400 900]);
    tl = tiledlayout(2,2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, 'Transient alignment QC', 'FontSize', 16, 'FontWeight', 'bold');

    % Choose display window
    if isfield(cfg, 'alignmentQcPpmRange')
        ppmRange = cfg.alignmentQcPpmRange;
    else
        ppmRange = [0 7];
    end

    % Extract spectra before and after alignment
    before = results.wsres;
    after  = results.wsres_proc.aligned;

    ppm = before.ppm(:);
    idx = ppm >= min(ppmRange) & ppm <= max(ppmRange);

    % Average dimension
    avgDim = before.dims.averages;

    if avgDim == 0
        error('No averages dimension found for transient QC.');
    end

    specsBefore = before.specs;
    specsAfter  = after.specs;

    % Move averages dimension to second dimension: [points x averages]
    specsBefore2D = reshape_to_points_by_averages(specsBefore, avgDim);
    specsAfter2D  = reshape_to_points_by_averages(specsAfter, avgDim);

    % ---------------------------------------------------------------------
    % 1. Before alignment
    % ---------------------------------------------------------------------
    nexttile;
    plot(ppm(idx), real(specsBefore2D(idx,:)), 'LineWidth', 0.7);
    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlabel('ppm');
    ylabel('Real(spec)');
    title('1. Transients before alignment');

    % ---------------------------------------------------------------------
    % 2. After alignment
    % ---------------------------------------------------------------------
    nexttile;
    plot(ppm(idx), real(specsAfter2D(idx,:)), 'LineWidth', 0.7);
    set(gca, 'XDir', 'reverse', 'FontSize', 11);
    xlabel('ppm');
    ylabel('Real(spec)');
    title('2. Transients after alignment');

    % ---------------------------------------------------------------------
    % 3. Frequency correction
    % ---------------------------------------------------------------------
    nexttile;
    plot(results.fs, '-o', 'LineWidth', 1.2);
    xlabel('Transient');
    ylabel('Frequency shift (Hz)');
    title('3. Estimated frequency correction');
    set(gca, 'FontSize', 11);
    yline(0, '--k');

    % ---------------------------------------------------------------------
    % 4. Phase correction
    % ---------------------------------------------------------------------
    nexttile;
    plot(results.phs, '-o', 'LineWidth', 1.2);
    xlabel('Transient');
    ylabel('Phase shift (degrees)');
    title('4. Estimated phase correction');
    set(gca, 'FontSize', 11);
    yline(0, '--k');

    figPath = fullfile(cfg.outputFigDir, ...
       sprintf('REF_%d__WSRES_%d_transient_alignment_qc_%.1f-%.1fppm.png', ...
       results.refScanNum, results.wsresNum, ...
       min(cfg.alignmentQcPpmRange), max(cfg.alignmentQcPpmRange)));

    exportgraphics(fig, figPath, 'Resolution', 150);
    close(fig);

    fprintf('Saved figure:\n%s\n', figPath);
end


function specs2D = reshape_to_points_by_averages(specs, avgDim)
% Reshape spectra so that columns correspond to individual transients.

    sz = size(specs);

    if avgDim > numel(sz)
        error('Average dimension exceeds number of dimensions in specs.');
    end

    % Move averages dimension to second dimension
    order = 1:numel(sz);
    order([2 avgDim]) = order([avgDim 2]);

    specsPerm = permute(specs, order);

    % Collapse all non-point/non-average dimensions
    specs2D = reshape(specsPerm, sz(1), []);
end
