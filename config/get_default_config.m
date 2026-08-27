function cfg = get_default_config()
% GET_DEFAULT_CONFIG
% Returns a configuration structure for the MRS preprocessing pipeline.

    %cfg.baseDir = '/mnt/data/projects/MAB_Dev/BrainTemp/Pilot-IRKA/Osprey_functions/Source_data/HT_nii-converted';
    cfg.baseDir = '/mnt/data/projects/MAB_Dev/BrainTemp/BrainTemp_reftest_nii-converted';
    cfg.wsDir   = fullfile(cfg.baseDir, 'MRS', 'WS');
    cfg.refDir  = fullfile(cfg.baseDir, 'MRS', 'REF');

    cfg.outputDir    = fullfile(cfg.baseDir, 'mrs_pipeline_output');
    cfg.outputMatDir = fullfile(cfg.outputDir, 'mat');
    cfg.outputFigDir = fullfile(cfg.outputDir, 'figures');

    cfg.ospreyPath = '/home/mohamed/Codes/MyGithub/osprey';

    %cfg.alignmentQcPpmRange = [0 7];
    %cfg.alignmentQcPpmRange = [1.6 2.2];
    %cfg.alignmentQcPpmRange = [4.4 5.0];



    % Alignment settings
    cfg.tmax = 0.20;
    cfg.alignRefMode = 'a';   % 'a' = average, 'n' = auto reference, etc.

    % Polarity correction settings
    cfg.waterPpmRange = [4.6 4.8];

    % NAA QC settings
    cfg.naaPpmRange = [1.8 2.4];

    % Peak fitting model
    % Options: 'lorentzian' or 'pseudovoigt'
    %cfg.fitModel = 'lorentzian';
    cfg.fitModel = 'pseudovoigt';

    % Optional tighter center constraints for thermometry
    cfg.waterCenterBounds = [4.5 4.9];
    cfg.naaCenterBounds   = [1.8 2.2];
    % Residual water removal settings
    cfg.applyWaterRemoval = true;

    % Thermometry peak windows
    cfg.waterFitPpmRange = [4.4 5.0];
    cfg.naaFitPpmRange   = [1.8 2.4];

    % Thermometry calibration
    % Temperature formula:
    %   T(°C) = 37 - 100 * (deltaPPM - 2.665)
    cfg.tempRefC = 37.0;
    cfg.tempDeltaRefPPM = 2.665;
    cfg.tempSlope = 100.0;
end
