function summaryN = run_refres_transient_stability_sequential(refresScanNum, nList)
% RUN_REFRES_TRANSIENT_STABILITY_SEQUENTIAL  How many transients are enough?
%
%   summaryN = RUN_REFRES_TRANSIENT_STABILITY_SEQUENTIAL(refresScanNum, nList)
%   re-runs REF_RES thermometry using only the first N transients, for
%   each N in nList, so you can see how the water peak, NAA peak, deltaPPM,
%   and temperature estimate converge as more transients (more averaging)
%   are included. Useful for choosing how many transients a real
%   acquisition actually needs.
%
%   Inputs
%   ------
%   refresScanNum : scan number of the REF_RES acquisition
%   nList         : (optional) vector of transient counts to test;
%                   defaults to [4 8 12 16 ... nTotal] if omitted
%
%   Output
%   ------
%   summaryN : table with one row per N (water/NAA ppm, deltaPPM,
%              temperature, as a function of N)
%
%   Example
%   -------
%       summaryN = run_refres_transient_stability_sequential(83);
%       summaryN = run_refres_transient_stability_sequential(83, [4 8 16 32 64]);
%
%   See also: RUN_THERMOMETRY_TRANSIENT_STABILITY_SEQUENTIAL,
%   PLOT_REFRES_TRANSIENT_STABILITY

    cfg = get_default_config();

    addpath(genpath(fileparts(fileparts(mfilename('fullpath'))))); % repo root, portable
    addpath(genpath(cfg.ospreyPath));
    rehash;

    ensure_dir_exists(cfg.outputDir);
    ensure_dir_exists(cfg.outputMatDir);
    ensure_dir_exists(cfg.outputFigDir);

    % ---------------------------------------------------------------------
    % Locate and load REF_RES file
    % ---------------------------------------------------------------------
    refresFile = find_refres_file(refresScanNum, cfg.refDir);
    dataPath = fullfile(refresFile.folder, refresFile.name);

    fprintf('REF_RES file:\n%s\n', dataPath);

    raw = patch_nii_mrs_provenance(load_nifti_mrs_generic(dataPath));

    % ---------------------------------------------------------------------
    % Detect total number of transients automatically
    % ---------------------------------------------------------------------
    avgDimRaw = raw.dims.averages;

    if avgDimRaw == 0
        error('No averages dimension found in REF_RES data.');
    end

    nTotal = size(raw.fids, avgDimRaw);

    fprintf('Detected number of REF_RES transients: %d\n', nTotal);

    % ---------------------------------------------------------------------
    % Automatically build nList if not provided
    % ---------------------------------------------------------------------
    if nargin < 2 || isempty(nList)

        nStep = 4;
        nList = nStep:nStep:nTotal;

        % Ensure the full number of transients is always included
        if isempty(nList) || nList(end) ~= nTotal
            nList = [nList nTotal];
        end
    end

    % Keep only valid N values
    nList = unique(nList(:)');
    nList = nList(nList <= nTotal);

    if isempty(nList)
        error('No N values are <= available transients (%d).', nTotal);
    end

    fprintf('Transient counts to test:\n');
    disp(nList);

    % ---------------------------------------------------------------------
    % Align all transients once
    % ---------------------------------------------------------------------
    [aligned, fs, phs] = step1_align_averages(raw, cfg);

    avgDim = aligned.dims.averages;

    if avgDim == 0
        error('No averages dimension found after alignment.');
    end

    % ---------------------------------------------------------------------
    % Sequential stability analysis
    % ---------------------------------------------------------------------
    rows = [];

    for iN = 1:numel(nList)

        N = nList(iN);
        idx = 1:N;

        fprintf('\nProcessing first %d transients...\n', N);

        % Select first N aligned transients
        subData = select_averages(aligned, idx);

        % Average selected transients
        avgData = step2_average(subData);

        % Fit water and NAA from the same unsuppressed averaged spectrum
        [waterFit, naaFit, thermo] = fit_water_and_naa_unsuppressed(avgData, cfg);

        % Store results
        row = table();

        row.REFRES_scan   = refresScanNum;
        row.N_transients  = N;

        row.water_ppm     = waterFit.centerPpm;
        row.naa_ppm       = naaFit.centerPpm;
        row.deltaPPM      = thermo.deltaPPM;
        row.temperature_C = thermo.temperatureC;

        if isfield(waterFit, 'gamma')
            row.water_gamma = waterFit.gamma;
        else
            row.water_gamma = NaN;
        end

        if isfield(naaFit, 'gamma')
            row.naa_gamma = naaFit.gamma;
        else
            row.naa_gamma = NaN;
        end

        if isfield(naaFit, 'sigma')
            row.naa_sigma = naaFit.sigma;
        else
            row.naa_sigma = NaN;
        end

        if isfield(naaFit, 'eta')
            row.naa_eta = naaFit.eta;
        else
            row.naa_eta = NaN;
        end

        if isfield(naaFit, 'A')
            row.naa_amplitude = naaFit.A;
        else
            row.naa_amplitude = NaN;
        end

        if isfield(naaFit, 'model')
            row.fit_model = string(naaFit.model);
        else
            row.fit_model = "";
        end

        row.mean_abs_fs_Hz   = mean(abs(fs(idx)));
        row.mean_abs_phs_deg = mean(abs(phs(idx)));

        rows = [rows; row]; %#ok<AGROW>

        fprintf('N = %d | water = %.5f | NAA = %.5f | delta = %.5f | T = %.3f °C\n', ...
            N, waterFit.centerPpm, naaFit.centerPpm, thermo.deltaPPM, thermo.temperatureC);
    end

    summaryN = rows;

    % ---------------------------------------------------------------------
    % Save outputs
    % ---------------------------------------------------------------------
    outCsv = fullfile(cfg.outputDir, ...
        sprintf('REFRES_%d_unsuppressed_transient_stability.csv', refresScanNum));

    outMat = fullfile(cfg.outputDir, ...
        sprintf('REFRES_%d_unsuppressed_transient_stability.mat', refresScanNum));

    writetable(summaryN, outCsv);
    save(outMat, 'summaryN');

    fprintf('\nSaved:\n%s\n%s\n', outCsv, outMat);

    % ---------------------------------------------------------------------
    % Plot summary
    % ---------------------------------------------------------------------
    plot_refres_transient_stability(summaryN, cfg, refresScanNum);
end
