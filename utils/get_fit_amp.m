function amp = get_fit_amp(fitStruct)
%GET_FIT_AMP Robust extraction of peak amplitude from fit structure.

    fields = {'amp','amplitude','A','height','peakAmp','peak_amp'};

    amp = NaN;

    for i = 1:numel(fields)
        f = fields{i};
        if isfield(fitStruct, f)
            val = fitStruct.(f);
            if isnumeric(val) && isscalar(val)
                amp = val;
                return;
            end
        end
    end
end
