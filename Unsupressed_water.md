# MRS Thermometry from Non Water-Suppressed Data

## Objective

The objective of this work was to explore the feasibility of estimating brain temperature directly from non water-suppressed MRS acquisitions (REF_RES), without relying on:
- a separate water reference acquisition
- a separate water-suppressed acquisition

The idea was to:
- simultaneously extract:
  - the water peak
  - the NAA peak
- from the same spectrum
- and compute the water–NAA chemical shift used for MR thermometry.

---

# Data Used

We used the acquisitions:

```text
REF_RES
```

for example:

```
eja-slaser_motor_ref_RES_83_MR.nii.gz
```

These acquisitions contain:

- a non-suppressed water peak
- visible metabolite peaks including NAA

# Developed Processing Pipeline

## 1. Data Loading

We created:

```
run_thermometry_refres_single(scanNum)
```

This function:

- automatically finds the REF_RES file
- loads the data using Osprey/FID-A
- runs the thermometry pipeline

------

# 2. Spectral Preprocessing

## Frequency and Phase Alignment

Transient alignment was performed using:

```
op_alignAverages
```

This step:

- estimates transient-wise frequency shifts
- estimates transient-wise phase shifts
- corrects them before averaging

This improves:

- spectral linewidth
- SNR
- peak stability

------

## Averaging

After correction:

- all transients are averaged
- resulting in a higher SNR spectrum

# 3. Water Peak Fitting

The water peak was fitted around ~4.68 ppm.

Implemented models:

- Lorentzian
- pseudo-Voigt

Extracted parameters:

- peak center frequency
- linewidth
- amplitude
- baseline

------

# 4. NAA Peak Fitting

The NAA peak was fitted around ~2.0 ppm.

The same fitting framework was used:

- Lorentzian

- pseudo-Voigt

  

# 5. Positive and Negative Peaks

## Observation

Some spectra exhibited:

- positive NAA peaks
- negative NAA peaks

Initially, fitting failed for negative peaks.

------

## Implemented Solution

The fitting functions were modified to:

- detect the dominant feature using:

```
max(abs(signal))
```

- allow:
  - positive amplitudes
  - negative amplitudes

This made the fitting pipeline robust to polarity inversions.

------

# 6. Temperature Calculation

Temperature estimation was based on:

```
Δppm = water_ppm - naa_ppm
```

Then converted using the standard calibration:

```
T(°C) = 286.9 - 101 * Δppm
```

# 7. QC Visualization

Automatic QC figures were generated showing:

## Before / After Alignment

- effect of frequency and phase correction

## Water Peak Fit

- raw data
- fitted curve
- fitted center frequency

## NAA Peak Fit

- raw data
- fitted curve
- fitted center frequency

## Summary Panel

- water ppm
- NAA ppm
- Δppm
- estimated temperature
- fit parameters

# 8. Signal Scale Interpretation

## Observation

The NAA peak sometimes appeared visually larger than the water peak.

This was due to:

- large baseline offsets
- different numerical signal scales
- MATLAB automatic axis scaling

------

## Implemented Solution

Automatic estimation of signal scale orders of magnitude was added:

```
Water fit panel: x10^8
NAA fit panel: x10^5
```

This removed ambiguity in the interpretation of the plotted amplitudes.

------

# 9. Multi-Scan Analysis

A batch processing script was developed to process multiple REF_RES scans:

```
[40 46 52 71 77 83]
```

and generate plots of:

## Temperature vs Scan

## Water Peak Position vs Scan

## NAA Peak Position vs Scan

## Water–NAA Chemical Shift vs Scan

------

# Main Findings

## Water Peak

The water peak can be fitted very precisely:

- extremely high SNR
- very stable frequency estimation

------

## Thermometry Feasibility

The results demonstrate that thermometry is feasible directly from REF_RES acquisitions.

However:

## Estimated temperatures were around ~41°C

This likely indicates:

- a systematic bias
- an imperfect calibration
- or residual global frequency offsets

Further validation will therefore be required.

------

# Important Methodological Notes

## The pipeline currently includes:

- transient-wise frequency correction
- transient-wise phase correction
- partial correction of global frequency drift through alignment

------

## The pipeline currently does NOT include:

- transient weighting
- automatic outlier rejection

All transients are currently averaged with equal weighting.

------

# Conclusion

This work demonstrates that it is possible to:

- estimate water position
- estimate NAA position
- estimate temperature

from a single non water-suppressed MRS acquisition.

This approach may:

- simplify acquisition protocols
- reduce acquisition time
- enable thermal monitoring from a single MRS sequence