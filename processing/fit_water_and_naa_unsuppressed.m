function [waterFit, naaFit, thermo] = fit_water_and_naa_unsuppressed(avgSpec, cfg)
% FIT_WATER_AND_NAA_UNSUPPRESSED
% Fits water and NAA peaks from the same unsuppressed averaged spectrum.

    waterFit = fit_water_peak(avgSpec, cfg);
    naaFit   = fit_naa_peak(avgSpec, cfg);

    thermo = compute_temperature_from_shift(waterFit, naaFit, cfg);
end