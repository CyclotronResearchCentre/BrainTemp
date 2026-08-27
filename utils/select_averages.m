function out = select_averages(in, idx)
% SELECT_AVERAGES
% Selects a subset of averages/transients from a FID-A/Osprey structure.

    out = in;

    avgDim = in.dims.averages;

    if avgDim == 0
        error('No averages dimension found.');
    end

    subs = repmat({':'}, 1, ndims(in.fids));
    subs{avgDim} = idx;

    out.fids = in.fids(subs{:});

    if isfield(in, 'specs') && ~isempty(in.specs)
        out.specs = in.specs(subs{:});
    end

    out.sz = size(out.fids);
    out.averages = numel(idx);

    if isfield(out, 'rawAverages')
        out.rawAverages = numel(idx);
    end

    if isfield(out, 'flags')
        out.flags.averaged = 0;
    end
end