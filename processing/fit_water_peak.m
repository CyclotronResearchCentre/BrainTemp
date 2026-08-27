function fitRes = fit_water_peak(in, cfg)
% FIT_WATER_PEAK
% Fits the water peak in the REF spectrum.

    fitRes = fit_peak_lorentzian(in, cfg.waterFitPpmRange, 'water');
end
