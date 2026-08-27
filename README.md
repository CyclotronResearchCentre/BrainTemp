# MRS Thermometry Pipeline

MATLAB pipeline for proton MR spectroscopy (¹H-MRS) thermometry using NIfTI-MRS data.

------

# Overview

This repository contains a modular MATLAB pipeline for:

- preprocessing NIfTI-MRS data
- transient alignment
- spectral averaging
- peak fitting
- MR thermometry
- transient stability analysis
- dynamic thermometry

The pipeline was developed within the **BrainTemp project** for methodological studies of temperature estimation using single-voxel spectroscopy (SVS).

------

# Scientific Background

MR thermometry exploits the temperature dependence of the water resonance frequency.

For proton spectroscopy:

Δδ = δ_water − δ_reference

where:

- water resonance shifts with temperature
- metabolite resonances remain comparatively stable

Temperature can therefore be estimated from chemical-shift differences.

------

# Supported Acquisition Types

The pipeline supports:

## REF

Unsuppressed water reference

Used for:

- water peak estimation
- eddy-current correction
- frequency referencing

------

## REF_RES

Transient-resolved unsuppressed acquisition

Used for:

- water thermometry
- transient stability analysis
- dynamic thermometry

------

## WS

Scanner-averaged water-suppressed spectrum

Used for:

- NAA peak estimation
- metabolite thermometry

------

## WS_RES

Transient-resolved water-suppressed acquisition

Used for:

- transient alignment
- frequency drift analysis
- optimized averaging

------

# Repository Structure

mrs_pipeline/

├── config/

├── io/

├── main/

├── plotting/

├── processing/

├── qc/

├── utils/

└── README.md

------

# Dependencies

## Required

MATLAB R2024a or newer

## External Toolboxes

### FID-A

Required for:

- spectral processing
- alignment
- FFT utilities

https://github.com/CIC-methods/FID-A

### Osprey

Required for:

- NIfTI-MRS import
- spectral registration
- preprocessing

https://github.com/schorschinho/osprey

------

# Configuration

Main configuration file:

config/get_default_config.m

Defines:

- data locations
- output folders
- fitting options
- preprocessing parameters

------

# Data Organization

Expected structure:

MRS/

├── REF/

│ └── **ref**.nii.gz

└── WS/

├── **ws**.nii.gz

└── **ws_RES**.nii.gz

NIfTI-MRS JSON sidecars must be available.

------

# Main Workflows

## Single REF_RES Thermometry

run_thermometry_refres_single(scanNum)

Example:

run_thermometry_refres_single(40)

Output:

- MAT summary
- thermometry figure

------

## Batch REF_RES Thermometry

run_thermometry_refres_all

Processes all available REF_RES scans.

------

## Transient Stability Analysis

run_refres_transient_stability_sequential(scanNum)

Evaluates:

- water peak stability
- NAA peak stability
- Δppm stability
- temperature stability

as a function of the number of averaged transients.

------

## Dynamic Thermometry

run_refres_thermometry_time_blocks(scanNum, blockSize)

Example:

run_refres_thermometry_time_blocks(40,4)

For:

TR = 2.25 s

block size = 4

Temporal resolution:

9 seconds

The acquisition is divided into sequential blocks:

[1-4]

[5-8]

[9-12]

...

Thermometry is computed independently for each block.

Outputs:

- CSV
- MAT
- PNG

------

# Processing Pipeline

Raw NIfTI-MRS

↓

Transient alignment

↓

Frequency correction

↓

Phase correction

↓

Averaging

↓

FFT

↓

Peak fitting

↓

Δppm estimation

↓

Temperature estimation

------

# Output Structure

mrs_pipeline_output/

├── figures/

├── mat/

└── *.csv

------

# Quality Control

Available QC tools:

- transient alignment plots
- frequency correction plots
- phase correction plots
- peak fitting summaries
- preprocessing diagnostics

------

# Current Applications

The pipeline is currently used for:

- phantom thermometry
- calibration studies
- transient stability studies
- temporal drift characterization
- MR thermometry methodology development

------

# Future Developments

Planned extensions:

- uncertainty estimation
- bootstrap thermometry
- confidence intervals
- automatic calibration fitting
- dynamic thermometry movies
- advanced drift correction
- MRSI thermometry support

------

# Citation

If you use this pipeline in scientific work, please cite:

BrainTemp Project

and the external software:

- Osprey
- FID-A
- NIfTI-MRS

------

# Authors

Developed within the BrainTemp project.

Research areas:

- MR Spectroscopy
- Thermometry
- NIfTI-MRS
- Quantitative MRI
- Signal Processing