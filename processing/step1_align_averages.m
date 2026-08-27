function [out, fs, phs] = step1_align_averages(in, cfg)
% STEP1_ALIGN_AVERAGES
% Step 1 of the Osprey-like preprocessing pipeline:
% time-domain spectral registration of individual transients.

    in = patch_nii_mrs_provenance(in);

    [out, fs, phs] = op_alignAverages(in, cfg.tmax, cfg.alignRefMode);

    out = patch_nii_mrs_provenance(out);
end