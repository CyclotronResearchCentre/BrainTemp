function summaryT = run_refres_thermometry_time_blocks(refresScanNum, blockSize)
%RUN_REFRES_THERMOMETRY_TIME_BLOCKS  Time-resolved (dynamic) thermometry.
%
%   summaryT = RUN_REFRES_THERMOMETRY_TIME_BLOCKS(refresScanNum, blockSize)
%   splits a REF_RES acquisition's transients into consecutive,
%   non-overlapping blocks of blockSize (e.g. transients [1-4], [5-8],
%   [9-12], ...) and computes thermometry independently for each block,
%   giving a temperature-vs-time curve rather than a single value. For
%   TR = 2.25 s and blockSize = 4, temporal resolution is 9 s.
%
%   Inputs
%   ------
%   refresScanNum : scan number of the REF_RES acquisition
%   blockSize     : number of transients per block (default: 4)
%
%   Output
%   ------
%   summaryT : table with one row per time block (block index, time,
%              temperature, deltaPPM, water/NAA ppm)
%
%   Saved outputs: CSV, MAT, and PNG in cfg.outputDir
%
%   Example
%   -------
%       summaryT = run_refres_thermometry_time_blocks(40, 4);
%
%   See also: RUN_THERMOMETRY_REFRES_SINGLE, PLOT_REFRES_THERMOMETRY_TIME_BLOCKS

    if nargin < 1 || isempty(refresScanNum)
        error('Usage: summaryT = run_refres_thermometry_time_blocks(refresScanNum, blockSize)');
    end

    if nargin < 2 || isempty(blockSize)
        blockSize = 4;
    end

    %% Config
    cfg = get_default_config();

    ensure_dir_exists(cfg.outputDir);
    ensure_dir_exists(cfg.outputMatDir);
    ensure_dir_exists(cfg.outputFigDir);

    %% Find REF_RES file
    refresFile = find_refres_file(refresScanNum, cfg.refDir);
    dataPath = fullfile(refresFile.folder, refresFile.name);
    jsonPath = strrep(dataPath, '.nii.gz', '.json');

    if ~isfile(jsonPath)
        error('JSON sidecar not found: %s', jsonPath);
    end

    fprintf('\n============================================================\n');
    fprintf('REF_RES dynamic thermometry by blocks\n');
    fprintf('REF_RES scan : %d\n', refresScanNum);
    fprintf('Data         : %s\n', dataPath);
    fprintf('JSON         : %s\n', jsonPath);
    fprintf('Block size   : %d transients\n', blockSize);
    fprintf('Output root  : %s\n', cfg.outputDir);
    fprintf('Figure dir   : %s\n', cfg.outputFigDir);
    fprintf('MAT dir      : %s\n', cfg.outputMatDir);
    fprintf('============================================================\n\n');

    %% Read TR
    js = jsondecode(fileread(jsonPath));

    if isfield(js, 'RepetitionTime')
        TR = js.RepetitionTime;
    else
        warning('RepetitionTime not found in JSON. Using TR = 1 s.');
        TR = 1;
    end

    fprintf('RepetitionTime = %.6f s\n', TR);

    %% Load data
    raw = io_loadspec_niimrs(dataPath);

    %% Preprocess all transients once
    fprintf('Preprocessing REF_RES...\n');
    fprintf('Aligning all transients once before block averaging.\n');

    proc = preprocess_unsuppressed_for_thermometry(raw, cfg);

    if ~isfield(proc, 'aligned')
        error('preprocess_unsuppressed_for_thermometry did not return proc.aligned.');
    end

    aligned = proc.aligned;

    %% Number of transients
    avgDim = aligned.dims.averages;

    if avgDim == 0
        error('No averages dimension found in aligned data.');
    end

    nTotal = aligned.sz(avgDim);
    nBlocks = floor(nTotal / blockSize);

    if nBlocks < 1
        error('Not enough transients (%d) for blockSize = %d.', nTotal, blockSize);
    end

    nUsed = nBlocks * blockSize;
    nIgnored = nTotal - nUsed;

    fprintf('Total transients : %d\n', nTotal);
    fprintf('Used transients  : %d\n', nUsed);
    fprintf('Ignored tail     : %d\n', nIgnored);
    fprintf('Number of blocks : %d\n', nBlocks);

    %% Allocate
    blockIndex = (1:nBlocks).';
    idxStart   = nan(nBlocks,1);
    idxEnd     = nan(nBlocks,1);
    timeSec    = nan(nBlocks,1);
    timeMin    = nan(nBlocks,1);

    waterPPM   = nan(nBlocks,1);
    naaPPM     = nan(nBlocks,1);
    deltaPPM   = nan(nBlocks,1);
    tempC      = nan(nBlocks,1);

    waterAmp   = nan(nBlocks,1);
    naaAmp     = nan(nBlocks,1);

    %% Block-wise analysis
    fprintf('\nRunning block-wise thermometry...\n');

    for b = 1:nBlocks
        i1 = (b-1)*blockSize + 1;
        i2 = b*blockSize;
        idx = i1:i2;

        idxStart(b) = i1;
        idxEnd(b)   = i2;

        centerTransient = (i1 + i2) / 2;
        timeSec(b) = (centerTransient - 1) * TR;
        timeMin(b) = timeSec(b) / 60;

        try
            subData = select_averages(aligned, idx);
            avgData = step2_average(subData);

            [waterFit, naaFit, thermo] = fit_water_and_naa_unsuppressed(avgData, cfg);

            waterPPM(b) = get_fit_ppm(waterFit);
            naaPPM(b)   = get_fit_ppm(naaFit);

            if isfield(thermo, 'deltaPPM')
                deltaPPM(b) = thermo.deltaPPM;
            else
                deltaPPM(b) = waterPPM(b) - naaPPM(b);
            end

            if isfield(thermo, 'temperatureC')
                tempC(b) = thermo.temperatureC;
            end

            waterAmp(b) = get_fit_amp(waterFit);
            naaAmp(b)   = get_fit_amp(naaFit);

        catch ME
            warning('Block %d failed [%d:%d]: %s', b, i1, i2, ME.message);
        end
    end

    %% Table
    summaryT = table( ...
        blockIndex, idxStart, idxEnd, timeSec, timeMin, ...
        waterPPM, naaPPM, deltaPPM, tempC, waterAmp, naaAmp);

    %% Save CSV in cfg.outputDir
    outCsv = fullfile( ...
        cfg.outputDir, ...
        sprintf('REFRES_%d_unsuppressed_time_blocks_%dtransients.csv', ...
        refresScanNum, blockSize));

    writetable(summaryT, outCsv);
    fprintf('\nSaved table:\n%s\n', outCsv);

    %% Save MAT in cfg.outputMatDir
    outMat = fullfile( ...
        cfg.outputMatDir, ...
        sprintf('REFRES_%d_unsuppressed_time_blocks_%dtransients.mat', ...
        refresScanNum, blockSize));

    save(outMat, ...
        'summaryT', ...
        'cfg', ...
        'refresScanNum', ...
        'blockSize', ...
        'TR', ...
        'dataPath', ...
        'jsonPath');

    fprintf('Saved MAT:\n%s\n', outMat);

    %% Plot in cfg.outputFigDir
    plot_refres_thermometry_time_blocks( ...
        summaryT, ...
        cfg.outputFigDir, ...
        refresScanNum, ...
        blockSize, ...
        TR);

    %% Summary
    fprintf('\n============================================================\n');
    fprintf('Block-wise REF_RES summary\n');
    fprintf('REF_RES scan       : %d\n', refresScanNum);
    fprintf('Block size         : %d\n', blockSize);
    fprintf('Usable blocks      : %d / %d\n', sum(~isnan(deltaPPM)), nBlocks);
    fprintf('Mean water ppm     : %.6f\n', mean(waterPPM, 'omitnan'));
    fprintf('SD water ppm       : %.6f\n', std(waterPPM, 'omitnan'));
    fprintf('Mean NAA ppm       : %.6f\n', mean(naaPPM, 'omitnan'));
    fprintf('SD NAA ppm         : %.6f\n', std(naaPPM, 'omitnan'));
    fprintf('Mean delta ppm     : %.6f\n', mean(deltaPPM, 'omitnan'));
    fprintf('SD delta ppm       : %.6f\n', std(deltaPPM, 'omitnan'));

    if any(~isnan(tempC))
        fprintf('Mean temperature C : %.3f\n', mean(tempC, 'omitnan'));
        fprintf('SD temperature C   : %.3f\n', std(tempC, 'omitnan'));
    end

    fprintf('============================================================\n\n');
end


