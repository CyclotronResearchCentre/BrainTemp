function summaryTable = run_thermometry_all(refScanList)
% RUN_THERMOMETRY_ALL  Batch thermometry across multiple REF scans.
%
%   summaryTable = RUN_THERMOMETRY_ALL(refScanList) calls
%   RUN_THERMOMETRY_SINGLE on every REF scan in refScanList (or every REF
%   scan found in cfg.refDir, if omitted), then collects the results into
%   one summary table and one summary figure.
%
%   Input
%   -----
%   refScanList : (optional) vector of REF scan numbers to process;
%                 defaults to all REF scans found in cfg.refDir
%
%   Output
%   ------
%   summaryTable : MATLAB table with one row per scan (temperature,
%                  deltaPPM, water/NAA ppm, status)
%
%   Saved outputs
%   -------------
%   thermometry_summary.csv / .mat / .png in cfg.outputDir
%
%   Example
%   -------
%       summaryTable = run_thermometry_all();
%       summaryTable = run_thermometry_all([34 39 44 49 54]);
%
%   See also: RUN_THERMOMETRY_SINGLE, RUN_THERMOMETRY_REFRES_ALL

    % ---------------------------------------------------------------------
    % Load config and paths
    % ---------------------------------------------------------------------
    cfg = get_default_config();

    addpath(genpath(fileparts(fileparts(mfilename('fullpath'))))); % repo root, portable
    addpath(genpath(cfg.ospreyPath));
    rehash;

    ensure_dir_exists(cfg.outputDir);
    ensure_dir_exists(cfg.outputMatDir);
    ensure_dir_exists(cfg.outputFigDir);

    % ---------------------------------------------------------------------
    % Determine which REF scans to run
    % ---------------------------------------------------------------------
    if nargin < 1 || isempty(refScanList)
        refFiles = dir(fullfile(cfg.refDir, '*.nii.gz'));

        if isempty(refFiles)
            error('No REF files found in: %s', cfg.refDir);
        end

        refScanList = [];
        for k = 1:numel(refFiles)
            n = extract_scan_number(refFiles(k).name);
            if ~isempty(n)
                refScanList(end+1) = n; %#ok<AGROW>
            end
        end

        refScanList = sort(unique(refScanList));
    else
        refScanList = sort(unique(refScanList(:)'));
    end

    fprintf('REF scans to process:\n');
    disp(refScanList);

    % ---------------------------------------------------------------------
    % Preallocate summary storage
    % ---------------------------------------------------------------------
    nRuns = numel(refScanList);

    REF_scan         = nan(nRuns,1);
    WSRES_scan       = nan(nRuns,1);
    water_ppm        = nan(nRuns,1);
    naa_ppm          = nan(nRuns,1);
    deltaPPM         = nan(nRuns,1);
    temperature_C    = nan(nRuns,1);
    naa_amplitude    = nan(nRuns,1);
    water_gamma      = nan(nRuns,1);
    naa_gamma        = nan(nRuns,1);

    fit_model        = strings(nRuns,1);
    naa_fit_polarity = strings(nRuns,1);
    status           = strings(nRuns,1);
    message          = strings(nRuns,1);
    result_mat_path  = strings(nRuns,1);

    % ---------------------------------------------------------------------
    % Run thermometry for each REF scan
    % ---------------------------------------------------------------------
    for i = 1:nRuns
        thisRef = refScanList(i);
        REF_scan(i) = thisRef;

        fprintf('\n====================================================\n');
        fprintf('Running thermometry for REF scan %d (%d/%d)\n', thisRef, i, nRuns);
        fprintf('====================================================\n');

        try
            % Run the single-scan pipeline
            run_thermometry_single(thisRef);

            % Reconstruct expected results filename
            [~, wsresNum] = find_nearest_wsres_file(thisRef, cfg.wsDir);
            WSRES_scan(i) = wsresNum;

            resultMat = fullfile(cfg.outputMatDir, ...
                sprintf('REF_%d__WSRES_%d_thermometry.mat', thisRef, wsresNum));
            result_mat_path(i) = string(resultMat);

            if ~exist(resultMat, 'file')
                error('Expected results file not found: %s', resultMat);
            end

            S = load(resultMat, 'results');
            results = S.results;

            % Extract core outputs
            water_ppm(i)     = results.waterFit.centerPpm;
            naa_ppm(i)       = results.naaFit.centerPpm;
            deltaPPM(i)      = results.thermo.deltaPPM;
            temperature_C(i) = results.thermo.temperatureC;

            if isfield(results.naaFit, 'A')
                naa_amplitude(i) = results.naaFit.A;
                if results.naaFit.A >= 0
                    naa_fit_polarity(i) = "positive";
                else
                    naa_fit_polarity(i) = "negative";
                end
            end

            if isfield(results.waterFit, 'gamma')
                water_gamma(i) = results.waterFit.gamma;
            end
            if isfield(results.naaFit, 'gamma')
                naa_gamma(i) = results.naaFit.gamma;
            end

            if isfield(results.naaFit, 'model')
                fit_model(i) = string(results.naaFit.model);
            end

            status(i) = "ok";
            message(i) = "";

        catch ME
            warning('Failed for REF scan %d: %s', thisRef, ME.message);
            status(i) = "failed";
            message(i) = string(ME.message);
        end
    end

    % ---------------------------------------------------------------------
    % Build summary table
    % ---------------------------------------------------------------------
    summaryTable = table( ...
        REF_scan, ...
        WSRES_scan, ...
        water_ppm, ...
        naa_ppm, ...
        deltaPPM, ...
        temperature_C, ...
        naa_amplitude, ...
        water_gamma, ...
        naa_gamma, ...
        fit_model, ...
        naa_fit_polarity, ...
        status, ...
        message, ...
        result_mat_path);

    % ---------------------------------------------------------------------
    % Save summary table
    % ---------------------------------------------------------------------
    summaryCsvPath = fullfile(cfg.outputDir, 'thermometry_summary.csv');
    summaryMatPath = fullfile(cfg.outputDir, 'thermometry_summary.mat');

    writetable(summaryTable, summaryCsvPath);
    save(summaryMatPath, 'summaryTable');

    fprintf('\nSummary saved to:\n%s\n%s\n', summaryCsvPath, summaryMatPath);

    % ---------------------------------------------------------------------
    % Summary figure
    % ---------------------------------------------------------------------
    plot_thermometry_summary(summaryTable, cfg);

    fprintf('\nSuccessful runs:\n');
    disp(summaryTable(summaryTable.status == "ok", :));
end
