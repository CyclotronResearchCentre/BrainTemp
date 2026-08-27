function [metab_out, ref_out] = step_ecc_klose(metab_in, ref_in)
% STEP_ECC_KLOSE
% Applies Klose eddy-current correction using an unsuppressed water reference.
%
% Inputs:
%   metab_in : metabolite spectrum structure
%   ref_in   : water reference spectrum structure
%
% Outputs:
%   metab_out : ECC-corrected metabolite spectrum
%   ref_out   : output reference spectrum returned by op_eccKlose

    metab_in = patch_nii_mrs_provenance(metab_in);
    ref_in   = patch_nii_mrs_provenance(ref_in);

    if exist('op_eccKlose', 'file') ~= 2
        error('op_eccKlose not found on MATLAB path.');
    end

    [metab_out, ref_out] = op_eccKlose(metab_in, ref_in);

    metab_out = patch_nii_mrs_provenance(metab_out);
    ref_out   = patch_nii_mrs_provenance(ref_out);
end