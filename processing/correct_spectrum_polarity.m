function [out, flipped, peakValue] = correct_spectrum_polarity(in, ppmRange)
% CORRECT_SPECTRUM_POLARITY
% Automatically determines the correct spectrum polarity from the residual
% water region. If the dominant peak in the water region is negative, the
% spectrum is flipped.
%
% Inputs:
%   in       : spectrum structure with .ppm, .specs, and .fids fields
%   ppmRange : e.g. [4.6 4.8]
%
% Outputs:
%   out      : corrected structure
%   flipped  : true if polarity was inverted
%   peakValue: dominant peak value in the requested ppm range

    if nargin < 2
        ppmRange = [4.6 4.8];
    end

    out = in;
    flipped = false;
    peakValue = NaN;

    if ~isfield(in, 'ppm')
        error('Input structure does not contain a ppm axis.');
    end

    if ~isfield(in, 'specs') || ~isfield(in, 'fids')
        error('Input structure must contain both .specs and .fids.');
    end

    ppm = in.ppm(:);
    specReal = real(in.specs(:));

    idx = ppm >= min(ppmRange) & ppm <= max(ppmRange);
    if ~any(idx)
        error('No points found in the selected ppm range.');
    end

    localSpec = specReal(idx);

    % Find the dominant peak by absolute amplitude
    [~, imax] = max(abs(localSpec));
    peakValue = localSpec(imax);

    % If the residual water peak is negative, flip the whole spectrum
    if peakValue < 0
        out.specs = -in.specs;
        out.fids  = -in.fids;
        flipped = true;
    end
end