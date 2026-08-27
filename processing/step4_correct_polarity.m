function [out, flipped, peakValue] = step4_correct_polarity(in, cfg)
% STEP4_CORRECT_POLARITY
% Step 4 of the preprocessing pipeline:
% automatic polarity correction using the residual water region.

    [out, flipped, peakValue] = correct_spectrum_polarity(in, cfg.waterPpmRange);
    out = patch_nii_mrs_provenance(out);
end