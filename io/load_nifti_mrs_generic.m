function out = load_nifti_mrs_generic(fname)
% LOAD_NIFTI_MRS_GENERIC
% Loads a NIfTI-MRS file using whichever loader is available on the path.

    if exist('io_loadspec_niimrs', 'file') == 2
        out = io_loadspec_niimrs(fname);
        return;
    end

    if exist('osp_LoadNII', 'file') == 2
        out = osp_LoadNII(fname);
        return;
    end

    if exist('nii_mrs_load', 'file') == 2
        out = nii_mrs_load(fname);
        return;
    end

    error(['No NIfTI-MRS loader found. Need one of: ' ...
           'io_loadspec_niimrs, osp_LoadNII, nii_mrs_load']);
end