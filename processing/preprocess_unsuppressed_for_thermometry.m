function proc = preprocess_unsuppressed_for_thermometry(in, cfg)
% PREPROCESS_UNSUPPRESSED_FOR_THERMOMETRY
% Preprocess unsuppressed multi-transient MRS data.
%
% Steps:
%   1) align transients
%   2) average
%   3) keep full unsuppressed spectrum for water + NAA fitting

    in = patch_nii_mrs_provenance(in);

    if isfield(in, 'dims') && isfield(in.dims, 'averages') && in.dims.averages ~= 0
        [aligned, fs, phs] = step1_align_averages(in, cfg);
        avg_before = step2_average(in);
        avg_after  = step2_average(aligned);
    else
        aligned = in;
        avg_before = in;
        avg_after = in;
        fs = [];
        phs = [];
    end

    proc = struct();
    proc.input = in;
    proc.aligned = aligned;
    proc.avg_before = avg_before;
    proc.avg_after = avg_after;
    proc.fs = fs;
    proc.phs = phs;
end