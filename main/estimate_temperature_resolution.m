function estimate_temperature_resolution(results, summaryTable)
% ESTIMATE_TEMPERATURE_RESOLUTION  How precise can this measurement be?
%
%   ESTIMATE_TEMPERATURE_RESOLUTION(results, summaryTable) prints two
%   independent estimates of the pipeline's temperature precision:
%     1) Digital resolution — the smallest temperature step the spectral
%        digitization (Hz/point) can in principle resolve, converted via
%        the PRF slope (dT/d(deltaPPM) = 100 degC/ppm).
%     2) Empirical repeatability — the mean and standard deviation of
%        temperature across repeated "ok" runs in summaryTable, i.e. what
%        precision is actually achieved in practice.
%
%   Inputs
%   ------
%   results      : a results struct from RUN_THERMOMETRY_REFRES_SINGLE (or
%                  similar) with results.wsres.{spectralwidth,sz,txfrq}
%   summaryTable : (optional) a summary table from RUN_THERMOMETRY_ALL /
%                  RUN_THERMOMETRY_REFRES_ALL, used for the empirical part
%
%   See also: RUN_THERMOMETRY_REFRES_SINGLE, RUN_THERMOMETRY_ALL

    % --- Digital spectral resolution ---
    sw_Hz = results.wsres.spectralwidth;
    nPts  = results.wsres.sz(1);
    txfrq_Hz = results.wsres.txfrq;

    hz_per_point = sw_Hz / nPts;
    ppm_per_point = hz_per_point / (txfrq_Hz / 1e6);

    temp_per_point = 100 * ppm_per_point;   % because dT/d(deltaPPM)=100

    fprintf('Digital resolution:\n');
    fprintf('  Hz/point   = %.6f\n', hz_per_point);
    fprintf('  ppm/point  = %.6f\n', ppm_per_point);
    fprintf('  degC/point = %.6f\n', temp_per_point);

    % --- Empirical repeatability ---
    if nargin > 1 && ~isempty(summaryTable)
        okIdx = summaryTable.status == "ok";
        T = summaryTable.temperature_C(okIdx);

        if numel(T) > 1
            fprintf('\nEmpirical repeatability:\n');
            fprintf('  mean(T) = %.4f °C\n', mean(T, 'omitnan'));
            fprintf('  std(T)  = %.4f °C\n', std(T, 'omitnan'));
        end
    end
end