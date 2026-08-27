function proc = preprocess_wsres_for_naa(in, ref_avg, cfg)
% PREPROCESS_WSRES_FOR_NAA
% Preprocesses WS_RES for NAA fitting and returns intermediate steps
% for QC / plotting.
%
% Processing order:
%   1) alignment
%   2) averaging
%   3) ECC with averaged REF
%   4) polarity correction
%   5) residual water removal

    in = patch_nii_mrs_provenance(in);
    ref_avg = patch_nii_mrs_provenance(ref_avg);

    if ~isfield(in, 'dims') || ~isfield(in.dims, 'averages') || in.dims.averages == 0
        error('WS_RES does not contain an averages dimension.');
    end

    % Step 1: alignment
    [aligned, fs, phs] = step1_align_averages(in, cfg);

    % Step 2: averaging
    avg_before = step2_average(in);
    avg_after  = step2_average(aligned);

    % Step ECC: eddy-current correction using averaged REF
    [ecc, ref_ecc] = step_ecc_klose(avg_after, ref_avg);

    % Step 4: polarity correction
    [polcorr, flipped, peakValue] = step4_correct_polarity(ecc, cfg);

    % Step 5: residual water removal
    if isfield(cfg, 'applyWaterRemoval') && cfg.applyWaterRemoval
        water_removed = step5_remove_residual_water(polcorr, cfg.waterPpmRange);
    else
        water_removed = polcorr;
    end

    % Optional NAA QC
    naaQC_before = check_naa_sign(avg_after, cfg.naaPpmRange);
    naaQC_afterECC = check_naa_sign(ecc, cfg.naaPpmRange);
    naaQC_afterPol = check_naa_sign(polcorr, cfg.naaPpmRange);
    naaQC_afterWater = check_naa_sign(water_removed, cfg.naaPpmRange);

    % Pack outputs
    proc = struct();
    proc.input = in;
    proc.aligned = aligned;

    proc.avg_before = avg_before;
    proc.avg_after = avg_after;

    proc.ecc = ecc;
    proc.ref_ecc = ref_ecc;

    proc.polcorr = polcorr;
    proc.water_removed = water_removed;

    proc.fs = fs;
    proc.phs = phs;

    proc.flipped = flipped;
    proc.peakValue = peakValue;

    proc.naaQC_before = naaQC_before;
    proc.naaQC_afterECC = naaQC_afterECC;
    proc.naaQC_afterPol = naaQC_afterPol;
    proc.naaQC_afterWater = naaQC_afterWater;
end