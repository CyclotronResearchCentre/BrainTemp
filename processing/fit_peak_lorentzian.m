function fitRes = fit_peak_lorentzian(in, ppmRange, peakName)
% FIT_PEAK_LORENTZIAN
% Fits a single Lorentzian peak in a selected ppm range with soft bounds.
%
% Model:
%   y = c0 + c1*x + A ./ (1 + ((x-x0)/gamma).^2)
%
% This version allows both positive and negative peaks.

    if nargin < 3
        peakName = 'peak';
    end

    ppm = in.ppm(:);
    y = real(in.specs(:));

    idx = ppm >= min(ppmRange) & ppm <= max(ppmRange);
    if ~any(idx)
        error('No points found in the selected ppm range.');
    end

    xfit = ppm(idx);
    yfit = y(idx);

    % Initial guesses from the dominant feature (positive or negative)
    y0 = median(yfit);
    [~, imax] = max(abs(yfit - y0));
    x0_init = xfit(imax);
    A_init = yfit(imax) - y0;

    gamma_init = 0.03;
    c0_init = y0;
    c1_init = 0;

    p0 = [A_init, x0_init, gamma_init, c0_init, c1_init];

    % Soft bounds
    xmin = min(ppmRange);
    xmax = max(ppmRange);
    gammaMin = 0.001;
    gammaMax = 0.2;

    modelFun = @(p, x) p(4) + p(5).*x + p(1) ./ (1 + ((x - p(2))./p(3)).^2);

    objFun = @(p) local_objective_with_penalty( ...
        p, xfit, yfit, modelFun, xmin, xmax, gammaMin, gammaMax);

    opts = optimset('Display', 'off', 'MaxFunEvals', 5000, 'MaxIter', 5000);
    p = fminsearch(objFun, p0, opts);

    yhat = modelFun(p, xfit);
    residual = yfit - yhat;

    fitRes = struct();
    fitRes.peakName = peakName;
    fitRes.ppmRange = ppmRange;
    fitRes.x = xfit;
    fitRes.y = yfit;
    fitRes.yhat = yhat;
    fitRes.residual = residual;

    fitRes.A = p(1);
    fitRes.centerPpm = p(2);
    fitRes.gamma = abs(p(3));
    fitRes.c0 = p(4);
    fitRes.c1 = p(5);
    fitRes.model = 'lorentzian';
end


function err = local_objective_with_penalty(p, xfit, yfit, modelFun, xmin, xmax, gammaMin, gammaMax)

    yhat = modelFun(p, xfit);
    err = sum((yfit - yhat).^2);

    penalty = 0;

    % Penalize center outside fitting window
    if p(2) < xmin
        penalty = penalty + 1e12 * (xmin - p(2))^2;
    end
    if p(2) > xmax
        penalty = penalty + 1e12 * (p(2) - xmax)^2;
    end

    % Penalize invalid linewidth
    if p(3) < gammaMin
        penalty = penalty + 1e12 * (gammaMin - p(3))^2;
    end
    if p(3) > gammaMax
        penalty = penalty + 1e12 * (p(3) - gammaMax)^2;
    end

    % IMPORTANT:
    % Do NOT penalize negative amplitudes.
    % This allows fitting downward peaks.

    err = err + penalty;
end
