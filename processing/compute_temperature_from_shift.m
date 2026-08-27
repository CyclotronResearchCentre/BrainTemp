function thermo = compute_temperature_from_shift(waterFit, naaFit, cfg)
% COMPUTE_TEMPERATURE_FROM_SHIFT
% Computes water-NAA chemical shift difference and converts it to temperature.
%
% Formula:
%   deltaPPM = water_ppm - naa_ppm
%   T(°C) = Tref - slope * (deltaPPM - deltaRef)
%
% Example:
%   T(°C) = 37 - 100 * (deltaPPM - 2.665)

    deltaPPM = waterFit.centerPpm - naaFit.centerPpm;
    temperatureC = cfg.tempRefC - cfg.tempSlope * (deltaPPM - cfg.tempDeltaRefPPM);

    thermo = struct();
    thermo.waterPpm = waterFit.centerPpm;
    thermo.naaPpm = naaFit.centerPpm;
    thermo.deltaPPM = deltaPPM;
    thermo.temperatureC = temperatureC;

    thermo.model = 'T = Tref - slope * (deltaPPM - deltaRef)';
    thermo.Tref = cfg.tempRefC;
    thermo.deltaRefPPM = cfg.tempDeltaRefPPM;
    thermo.slope = cfg.tempSlope;
end
