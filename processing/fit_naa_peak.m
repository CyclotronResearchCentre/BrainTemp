function fitRes = fit_naa_peak(in, cfg)
% FIT_NAA_PEAK
% Fits the NAA peak using the selected model.

    switch lower(cfg.fitModel)
        case 'lorentzian'
            fitRes = fit_peak_lorentzian(in, cfg.naaFitPpmRange, 'NAA');
        case 'pseudovoigt'
            fitRes = fit_peak_pseudovoigt(in, cfg.naaFitPpmRange, ...
                'NAA', cfg.naaCenterBounds);
        otherwise
            error('Unknown fit model: %s', cfg.fitModel);
    end
end
