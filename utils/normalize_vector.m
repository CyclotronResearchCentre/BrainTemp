function y = normalize_vector(x)
% NORMALIZE_VECTOR
% Scales a vector by its maximum absolute value.

    x = x(:);
    xmax = max(abs(x));

    if xmax == 0
        y = x;
    else
        y = x ./ xmax;
    end
end