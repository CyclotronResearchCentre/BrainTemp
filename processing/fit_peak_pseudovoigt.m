function fitRes = fit_peak_pseudovoigt(in, ppmRange, peakName, centerBounds)
% FIT_PEAK_PSEUDOVOIGT
% Fits a single peak with a pseudo-Voigt model:
%
%   y = c0 + c1*x + A * [ eta * L(x) + (1-eta) * G(x) ]
%
% where:
%   L(x) = 1 / (1 + ((x-x0)/gamma).^2)
%   G(x) = exp( -log(2) * ((x-x0)/sigma).^2 )
%
% Inputs
%   in           : structure with .ppm and .specs
%   ppmRange     : fitting window
%   peakName     : string, e.g. 'water' or 'NAA'
%   centerBounds : optional [xmin xmax] constraint for x0
%
% Output
%   fitRes       : structure with fitted parameters and curves
%
% This version allows both positive and negative peaks.

    if nargin < 3 || isempty(peakName)
        peakName = 'peak';
    end

    if nargin < 4 || isempty(centerBounds)
        centerBounds = ppmRange;
    end

    ppm = in.ppm(:);
    y = real(in.specs(:));

    idx = ppm >= min(ppmRange) & ppm <= max(ppmRange);
    if ~any(idx)
        error('No points found in the selected ppm range.');
    end

    xfit = ppm(idx);
    yfit = y(idx);

    % Initial guess from dominant feature (positive or negative)
    y0 = median(yfit);
    [~, imax] = max(abs(yfit - y0));
    x0_init = xfit(imax);
    A_init = yfit(imax) - y0;

    gamma_init = 0.01;
    sigma_init = 0.01;
    eta_init = 0.5;
    c0_init = y0;
    c1_init = 0;

    % Parameter vector:
    % p = [A, x0, gamma, sigma, eta, c0, c1]
    p0 = [A_init, x0_init, gamma_init, sigma_init, eta_init, c0_init, c1_init];

    xmin = centerBounds(1);
    xmax = centerBounds(2);

    gammaMin = 0.001;
    gammaMax = 0.2;

    sigmaMin = 0.001;
    sigmaMax = 0.2;

    etaMin = 0.0;
    etaMax = 1.0;

    modelFun = @(p, x) local_pseudovoigt_model(p, x);

    objFun = @(p) local_objective_with_penalty( ...
        p, xfit, yfit, modelFun, ...
        xmin, xmax, ...
        gammaMin, gammaMax, ...
        sigmaMin, sigmaMax, ...
        etaMin, etaMax);

    opts = optimset('Display', 'off', 'MaxFunEvals', 10000, 'MaxIter', 10000);
    p = fminsearch(objFun, p0, opts);

    yhat = modelFun(p, xfit);
    residual = yfit - yhat;

    fitRes = struct();
    fitRes.peakName = peakName;
    fitRes.ppmRange = ppmRange;
    fitRes.centerBounds = centerBounds;

    fitRes.x = xfit;
    fitRes.y = yfit;
    fitRes.yhat = yhat;
    fitRes.residual = residual;

    fitRes.A = p(1);
    fitRes.centerPpm = p(2);
    fitRes.gamma = abs(p(3));
    fitRes.sigma = abs(p(4));
    fitRes.eta = p(5);
    fitRes.c0 = p(6);
    fitRes.c1 = p(7);
    fitRes.model = 'pseudo-Voigt';
end


function yhat = local_pseudovoigt_model(p, x)
    A     = p(1);
    x0    = p(2);
    gamma = abs(p(3));
    sigma = abs(p(4));
    eta   = p(5);
    c0    = p(6);
    c1    = p(7);

    % Lorentzian
    L = 1 ./ (1 + ((x - x0) ./ gamma).^2);

    % Gaussian
    G = exp(-log(2) * ((x - x0) ./ sigma).^2);

    yhat = c0 + c1 .* x + A .* (eta .* L + (1 - eta) .* G);
end


function err = local_objective_with_penalty( ...
    p, xfit, yfit, modelFun, ...
    xmin, xmax, ...
    gammaMin, gammaMax, ...
    sigmaMin, sigmaMax, ...
    etaMin, etaMax)

    yhat = modelFun(p, xfit);
    err = sum((yfit - yhat).^2);

    penalty = 0;

    % x0 bounds
    if p(2) < xmin
        penalty = penalty + 1e12 * (xmin - p(2))^2;
    end
    if p(2) > xmax
        penalty = penalty + 1e12 * (p(2) - xmax)^2;
    end

    % gamma bounds
    if p(3) < gammaMin
        penalty = penalty + 1e12 * (gammaMin - p(3))^2;
    end
    if p(3) > gammaMax
        penalty = penalty + 1e12 * (p(3) - gammaMax)^2;
    end

    % sigma bounds
    if p(4) < sigmaMin
        penalty = penalty + 1e12 * (sigmaMin - p(4))^2;
    end
    if p(4) > sigmaMax
        penalty = penalty + 1e12 * (p(4) - sigmaMax)^2;
    end

    % eta bounds
    if p(5) < etaMin
        penalty = penalty + 1e12 * (etaMin - p(5))^2;
    end
    if p(5) > etaMax
        penalty = penalty + 1e12 * (p(5) - etaMax)^2;
    end

    % IMPORTANT:
    % Do NOT penalize negative amplitudes.
    % This allows fitting downward peaks.

    err = err + penalty;
end
