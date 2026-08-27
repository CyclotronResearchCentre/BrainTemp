function out = step5_remove_residual_water(in, ppmRange)
% STEP5_REMOVE_RESIDUAL_WATER
% Step 5 of the preprocessing pipeline:
% remove residual water from the spectrum.
%
% Inputs
%   in       : spectrum structure
%   ppmRange : optional, default = [4.6 4.8]
%
% Output
%   out      : water-suppressed output structure

    if nargin < 2 || isempty(ppmRange)
        ppmRange = [4.6 4.8];
    end

    in = patch_nii_mrs_provenance(in);

    if exist('op_removeWater', 'file') == 2
        % FID-A / Osprey implementation
        % Important: op_removeWater expects the water limits as a 2-element vector
        out = op_removeWater(in, ppmRange);
    else
        error(['op_removeWater not found on MATLAB path. ' ...
               'Please check whether this function exists in your Osprey/FID-A installation.']);
    end

    out = patch_nii_mrs_provenance(out);
end