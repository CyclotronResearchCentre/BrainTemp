function in = patch_nii_mrs_provenance(in)
% PATCH_NII_MRS_PROVENANCE
% Ensures that the NIfTI-MRS provenance/header fields expected by Osprey exist.

    if ~isfield(in, 'nii_mrs') || isempty(in.nii_mrs)
        in.nii_mrs = struct();
    end

    if ~isfield(in.nii_mrs, 'hdr_ext') || isempty(in.nii_mrs.hdr_ext)
        in.nii_mrs.hdr_ext = struct();
    end

    hdr = in.nii_mrs.hdr_ext;

    if ~isfield(hdr, 'ProcessingSoftwareName') || isempty(hdr.ProcessingSoftwareName)
        hdr.ProcessingSoftwareName = 'Unknown';
    end

    if ~isfield(hdr, 'ProcessingSoftwareVersion') || isempty(hdr.ProcessingSoftwareVersion)
        hdr.ProcessingSoftwareVersion = 'Unknown';
    end

    if ~isfield(hdr, 'ProcessingProvenance') || isempty(hdr.ProcessingProvenance)
        hdr.ProcessingProvenance = struct([]);
    end

    in.nii_mrs.hdr_ext = hdr;
end