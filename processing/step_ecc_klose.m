function [metab_out, ref_out] = step_ecc_klose(metab_in, ref_in)
% STEP_ECC_KLOSE  Eddy-current correction via the Klose method.
%
%   Removes phase distortion caused by gradient-induced eddy currents by
%   using the phase of an unsuppressed water reference as a per-point
%   correction for the metabolite spectrum. Delegates to FID-A/Osprey's
%   op_eccKlose, which implements:
%   Klose U. "In vivo proton spectroscopy in presence of eddy currents."
%   Magn Reson Med. 1990;14(1):26-30. doi:10.1002/mrm.1910140104
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