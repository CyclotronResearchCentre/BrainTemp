function [out, flipped, peakValue] = step4_correct_polarity_naa(in, ppmRange)
% STEP4_CORRECT_POLARITY_NAA
% Automatically determines spectrum polarity from the NAA region.
%
% Inputs
%   in       : FID-A / Osprey spectrum structure
%   ppmRange : optional, default = [1.8 2.2]
%
% Outputs
%   out      : output structure, possibly flipped
%   flipped  : true if polarity was inverted
%   peakValue: dominant peak value in the selected NAA window

    if nargin < 2 || isempty(ppmRange)
        ppmRange = [1.8 2.2];
    end

    if ~isfield(in, 'ppm') || ~isfield(in, 'specs') || ~isfield(in, 'fids')
        error('Input structure must contain .ppm, .specs, and .fids.');
    end

    out = in;
    flipped = false;
    peakValue = NaN;

    ppm = in.ppm(:);
    specReal = real(in.specs(:));

    idx = ppm >= min(ppmRange) & ppm <= max(ppmRange);
    if ~any(idx)
        error('No points found in the selected NAA ppm range.');
    end

    localSpec = specReal(idx);

    % Find dominant peak by absolute amplitude
    [~, imax] = max(abs(localSpec));
    peakValue = localSpec(imax);

    % Flip if dominant NAA-region peak is negative
    if peakValue < 0
        out.specs = -in.specs;
        out.fids  = -in.fids;
        flipped = true;
    end
end