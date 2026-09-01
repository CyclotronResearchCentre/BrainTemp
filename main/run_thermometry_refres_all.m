function summaryTable = run_thermometry_refres_all(refresScanList)
% RUN_THERMOMETRY_REFRES_ALL  Batch thermometry across REF_RES scans.
%
%   summaryTable = RUN_THERMOMETRY_REFRES_ALL(refresScanList) calls
%   RUN_THERMOMETRY_REFRES_SINGLE on each scan number in refresScanList
%   and collects the results into one summary table + figure. The
%   REF_RES (single-scan, unsuppressed) counterpart to RUN_THERMOMETRY_ALL.
%
%   Input
%   -----
%   refresScanList : (optional) vector of REF_RES scan numbers;
%                    defaults to [40 46 52 71 77 83] if omitted
%
%   Output
%   ------
%   summaryTable : MATLAB table with one row per scan
%
%   Example
%   -------
%       summaryTable = run_thermometry_refres_all([40 46 52 71 77 83]);
%
%   See also: RUN_THERMOMETRY_REFRES_SINGLE, RUN_THERMOMETRY_ALL

    if nargin < 1 || isempty(refresScanList)
        refresScanList = [40 46 52 71 77 83];
    end

    cfg = get_default_config();

    addpath(genpath(fileparts(fileparts(mfilename('fullpath'))))); % repo root, portable
    addpath(genpath(cfg.ospreyPath));
    rehash;

    ensure_dir_exists(cfg.outputDir);
    ensure_dir_exists(cfg.outputMatDir);
    ensure_dir_exists(cfg.outputFigDir);

    nRuns = numel(refresScanList);

    REFRES_scan   = nan(nRuns,1);
    water_ppm     = nan(nRuns,1);
    naa_ppm       = nan(nRuns,1);
    deltaPPM      = nan(nRuns,1);
    temperature_C = nan(nRuns,1);
    naa_amp       = nan(nRuns,1);
    naa_gamma     = nan(nRuns,1);
    fit_model     = strings(nRuns,1);
    status        = strings(nRuns,1);
    message       = strings(nRuns,1);

    for i = 1:nRuns
        scanNum = refresScanList(i);
        REFRES_scan(i) = scanNum;

        fprintf('\n========================================\n');
        fprintf('Running REF_RES scan %d (%d/%d)\n', scanNum, i, nRuns);
        fprintf('========================================\n');

        try
            results = run_thermometry_refres_single(scanNum);

            water_ppm(i)     = results.waterFit.centerPpm;
            naa_ppm(i)       = results.naaFit.centerPpm;
            deltaPPM(i)      = results.thermo.deltaPPM;
            temperature_C(i) = results.thermo.temperatureC;

            if isfield(results.naaFit, 'A')
                naa_amp(i) = results.naaFit.A;
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
            warning('Failed for REF_RES scan %d: %s', scanNum, ME.message);
            status(i) = "failed";
            message(i) = string(ME.message);
        end
    end

    summaryTable = table( ...
        REFRES_scan, ...
        water_ppm, ...
        naa_ppm, ...
        deltaPPM, ...
        temperature_C, ...
        naa_amp, ...
        naa_gamma, ...
        fit_model, ...
        status, ...
        message);

    outCsv = fullfile(cfg.outputDir, 'refres_unsuppressed_thermometry_summary.csv');
    outMat = fullfile(cfg.outputDir, 'refres_unsuppressed_thermometry_summary.mat');

    writetable(summaryTable, outCsv);
    save(outMat, 'summaryTable');

    fprintf('\nSaved summary:\n%s\n%s\n', outCsv, outMat);

    plot_refres_thermometry_summary(summaryTable, cfg);
end