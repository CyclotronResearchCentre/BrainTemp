function qc = check_naa_sign(in, ppmRange)
% CHECK_NAA_SIGN
% Checks the dominant sign in the NAA region without changing spectrum polarity.
%
% Inputs
%   in       : spectrum structure with .ppm and .specs
%   ppmRange : optional, default = [1.8 2.2]
%
% Outputs
%   qc       : structure with NAA sign information

    if nargin < 2 || isempty(ppmRange)
        ppmRange = [1.8 2.2];
    end

    if ~isfield(in, 'ppm') || ~isfield(in, 'specs')
        error('Input structure must contain .ppm and .specs.');
    end

    ppm = in.ppm(:);
    specReal = real(in.specs(:));

    idx = ppm >= min(ppmRange) & ppm <= max(ppmRange);
    if ~any(idx)
        error('No points found in the selected NAA ppm range.');
    end

    localSpec = specReal(idx);
    localPpm  = ppm(idx);

    [~, imax] = max(abs(localSpec));
    peakValue = localSpec(imax);
    peakPpm   = localPpm(imax);

    qc = struct();
    qc.method = 'NAA sign check';
    qc.ppmRange = ppmRange;
    qc.peakValue = peakValue;
    qc.peakPpm = peakPpm;
    qc.sign = sign(peakValue);

    if peakValue > 0
        qc.signLabel = 'positive';
    elseif peakValue < 0
        qc.signLabel = 'negative';
    else
        qc.signLabel = 'zero';
    end
end