function out = step2_average(in)
% STEP2_AVERAGE
% Step 2 of the preprocessing pipeline:
% average aligned transients into a single spectrum.

    out = op_averaging(in);
    out = patch_nii_mrs_provenance(out);
end