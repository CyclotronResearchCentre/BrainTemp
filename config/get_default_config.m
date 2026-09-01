function cfg = get_default_config()
% GET_DEFAULT_CONFIG  Default configuration for the MRS thermometry pipeline.
%
%   cfg = GET_DEFAULT_CONFIG() returns a struct with every setting the
%   pipeline needs: data locations, external toolbox paths, alignment/
%   fitting parameters, and the PRF temperature-calibration coefficients.
%
%   BEFORE FIRST USE, edit the two paths marked "<<< EDIT THIS" below to
%   match your own machine. Everything else has a sensible default and
%   only needs to change if your acquisition protocol differs from the
%   one this pipeline was built around (Siemens sLASER, water-suppressed +
%   unsuppressed single-voxel MRS).
%
%   See also: RUN_THERMOMETRY_REFRES_SINGLE, RUN_THERMOMETRY_SINGLE

    % ---------------------------------------------------------------
    % Data location  <<< EDIT THIS
    % ---------------------------------------------------------------
    % Root folder containing your converted NIfTI-MRS data, organized as:
    %   <baseDir>/MRS/REF/*.nii.gz   (unsuppressed water reference scans)
    %   <baseDir>/MRS/WS/*.nii.gz    (water-suppressed scans)
    cfg.baseDir = fullfile(pwd, 'data');   % placeholder: point this at your dataset
    cfg.wsDir   = fullfile(cfg.baseDir, 'MRS', 'WS');
    cfg.refDir  = fullfile(cfg.baseDir, 'MRS', 'REF');

    cfg.outputDir    = fullfile(cfg.baseDir, 'mrs_pipeline_output');
    cfg.outputMatDir = fullfile(cfg.outputDir, 'mat');
    cfg.outputFigDir = fullfile(cfg.outputDir, 'figures');

    % ---------------------------------------------------------------
    % External toolbox  <<< EDIT THIS
    % ---------------------------------------------------------------
    % Local path to your Osprey installation (https://github.com/schorschinho/osprey).
    % FID-A (https://github.com/CIC-methods/FID-A) is expected to already be
    % on the MATLAB path, or installable the same way.
    cfg.ospreyPath = fullfile(fileparts(fileparts(mfilename('fullpath'))), '..', 'osprey');

    % ---------------------------------------------------------------
    % Alignment settings
    % ---------------------------------------------------------------
    cfg.tmax = 0.20;
    cfg.alignRefMode = 'a';   % 'a' = average, 'n' = auto reference, etc.

    % Polarity correction settings
    cfg.waterPpmRange = [4.6 4.8];

    % NAA QC settings
    cfg.naaPpmRange = [1.8 2.4];

    % Peak fitting model
    % Options: 'lorentzian' or 'pseudovoigt'
    cfg.fitModel = 'pseudovoigt';

    % Optional tighter center constraints for thermometry
    cfg.waterCenterBounds = [4.5 4.9];
    cfg.naaCenterBounds   = [1.8 2.2];

    % Residual water removal settings
    cfg.applyWaterRemoval = true;

    % Thermometry peak windows
    cfg.waterFitPpmRange = [4.4 5.0];
    cfg.naaFitPpmRange   = [1.8 2.4];

    % ---------------------------------------------------------------
    % Thermometry calibration (PRF method)
    % ---------------------------------------------------------------
    %   T(degC) = tempRefC - tempSlope * (deltaPPM - tempDeltaRefPPM)
    %
    % Default coefficients follow the proton resonance frequency (PRF)
    % water-NAA calibration reported for brain MRS thermometry, e.g.
    % Thrippleton MJ, et al. "Reliability of MRSI brain temperature
    % mapping at 1.5 and 3 T." NMR Biomed. 2014;27(2):183-190.
    % doi:10.1002/nbm.3050
    % Re-derive these coefficients from your own phantom calibration
    % before relying on them for real temperature estimates.
    cfg.tempRefC = 37.0;
    cfg.tempDeltaRefPPM = 2.665;
    cfg.tempSlope = 100.0;
end
