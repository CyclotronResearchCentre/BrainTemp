function proc = preprocess_ref_for_water(in, cfg)
% PREPROCESS_REF_FOR_WATER
% Minimal preprocessing for water peak estimation, while also returning
% intermediate outputs for bookkeeping.

    in = patch_nii_mrs_provenance(in);

    if isfield(in, 'dims') && isfield(in.dims, 'averages') && in.dims.averages ~= 0
        [aligned, fs, phs] = step1_align_averages(in, cfg);
        avg = step2_average(aligned);
    else
        aligned = in;
        avg = in;
        fs = [];
        phs = [];
    end

    proc = struct();
    proc.input = in;
    proc.aligned = aligned;
    proc.avg = avg;
    proc.fs = fs;
    proc.phs = phs;
end