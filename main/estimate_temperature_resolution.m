function estimate_temperature_resolution(results, summaryTable)
% Estimate digital and empirical temperature resolution

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