function thermo = compute_temperature_from_shift(waterFit, naaFit, cfg)
% COMPUTE_TEMPERATURE_FROM_SHIFT  Water-NAA chemical shift to temperature (PRF method).
%
%   thermo = COMPUTE_TEMPERATURE_FROM_SHIFT(waterFit, naaFit, cfg) is the
%   core of the pipeline: it converts two fitted peak positions into a
%   single temperature estimate.
%
%   Method
%   ------
%   The water resonance shifts with temperature much more than the
%   N-acetylaspartate (NAA) resonance does, so their chemical-shift
%   separation, deltaPPM, is (over physiological ranges) an approximately
%   linear function of temperature — the proton resonance frequency (PRF)
%   method:
%
%       deltaPPM     = water_ppm - naa_ppm
%       T(degC)      = Tref - slope * (deltaPPM - deltaRef)
%
%   With the default coefficients (cfg.tempRefC = 37, cfg.tempSlope = 100,
%   cfg.tempDeltaRefPPM = 2.665):
%
%       T(degC) = 37 - 100 * (deltaPPM - 2.665)
%
%   These coefficients follow published PRF brain-thermometry calibrations,
%   e.g. Thrippleton MJ, et al. "Reliability of MRSI brain temperature
%   mapping at 1.5 and 3 T." NMR Biomed. 2014;27(2):183-190.
%   doi:10.1002/nbm.3050 — re-derive them from your own phantom
%   calibration before trusting absolute temperatures from this pipeline.
%
%   Inputs
%   ------
%   waterFit : struct with field .centerPpm — fitted water peak center,
%              from FIT_WATER_PEAK or FIT_PEAK_LORENTZIAN/FIT_PEAK_PSEUDOVOIGT.
%   naaFit   : struct with field .centerPpm — fitted NAA peak center,
%              from FIT_NAA_PEAK.
%   cfg      : config struct from GET_DEFAULT_CONFIG (needs .tempRefC,
%              .tempSlope, .tempDeltaRefPPM).
%
%   Output
%   ------
%   thermo : struct with fields waterPpm, naaPpm, deltaPPM, temperatureC,
%            plus the calibration model/coefficients used, for provenance.
%
%   Example
%   -------
%       waterFit.centerPpm = 4.70;
%       naaFit.centerPpm   = 2.01;
%       cfg = get_default_config();
%       thermo = compute_temperature_from_shift(waterFit, naaFit, cfg);
%       % thermo.deltaPPM = 2.69, thermo.temperatureC = 34.5
%
%   See also: FIT_WATER_PEAK, FIT_NAA_PEAK, GET_DEFAULT_CONFIG

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
