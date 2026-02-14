
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18642249.svg)](https://doi.org/10.5281/zenodo.18642249)

# MATLAB Tools for Gap Filling in Oceanographic Datasets

This repository provides MATLAB tools for gap-filling oceanographic datasets. TheSE tools are designed to generate gap-free climatological products for use in ocean biogeochemical modelling and analysis.

## Supported Data Types

These tools are divided into two categories based on the dataset interaction with sea ice:
- **Surface ocean data affected by ice coverage**, like chlorophyll *a* concentration, net primary preoduction, photosynthetic active radiation, aeolian flux deposition. Structure: `latitude x longitude x time` 
- **Ocean data not affected by ice coverage (surface or depth-resolved)**, like nitrate concentration, seawater temperature, mixed layer depth. Structure: `latitude x longitude x (depth) x time`

Currently, this repository focuses on gap-filling surface ocean datasets that require ice masking.

## Gap-Filling Strategy for Ice-Masked Surface Ocean Data

Satellite-derived surface ocean data often contain polar gaps due to cloud cover and sea ice. To distinguish between true biological inactivity and satellite-imposed data gaps, a custom sea-ice threshold mask was developed using monthly climatological data of chlorophyll *a* from ESA OC-CCI ([Sathyendranath et al., 2023](https://doi.org/10.5285/5011d22aae5a4671b0cbc7d05c56c4f0)) and sea ice fraction from the ESA Sea Ice Climate Change Initiative ([Toudal Pedersen et al., 2017](https://doi.org/10.5285/5f75fcb0c58740d99b07953797bc041e)). Chlorophyll *a* values are retained only where the sea ice fraction remains below a biologically informed threshold. The custom mask is saved as `mask_custom_icefrac_cmems_chla_occci.mat`. 

Gap-filling is first performed in time (not in space), since satellite coverage ensures spatial completeness over open ocean. Grid cells missing values for the entire time series typically correspond to land or permanently ice-covered regions. The script `manageGapsInOceanDataIceMasked.m` provides two gap-filling options:
- Standard interpolation: uses MATLAB's `interp1` function for straightforward gap-filling.
- Custom multi-step interpolation, which fills gaps in two stages:
    - Internal gaps: interpolates missing values surrounded by valid data on both sides.
    - Edge gaps: extrapolates values at the beginning or end of the time series using a flip-based interpolation approach.

After interpolation, the custom sea-ice threshold mask is applied.

To validate the approach, gap-filled NPP products were compared across four commonly used models:
- Vertically Generalized Production Model (VGPM) 
- Carbon-based Production Model (CbPM) 
- CAFE model
- ESA BICEP multi-sensor product

A visual comparative analysis is available in a separate GitHub repository: [npp-product-comparison](https://github.com/annarufas/npp-product-comparison). Gap-filling resulted in the creation of global products with reduced gaps and increased the global annual mean NPP from: **46 to 47 Gt C yr<sup>−1</sup>** for the BICEP product, **49 to 50 Gt C yr<sup>−1</sup>** for the VGPM product (MODIS-Aqua), **60 to 61 Gt C yr<sup>−1</sup>** for the CAFE product (MODIS-Aqua), and **66 to 68 Gt C yr<sup>−1</sup>** for the CbPM product (MODIS-Aqua).

## Gap-Filling for Other Oceanographic Datasets

In contrast to satellite-based surface ocean data, most other oceanographic datasets typically lack spatial and temporal gaps, as they are often pre-processed with gap-filling algorithms by the data providers, and are not affected by cloud cover. 

However, missing values can still occur at depth as well as in regions near continental margins due to sparse sampling. For example, the World Ocean Atlas 2023 exhibits persistent coverage gaps below 800 m for macronutrients and below 1500 m for temperature and oxygen.

To address such cases, a targeted vertical interpolation approach is applied using a neighbourhood-mean search algorithm. This method fills persistent missing grid cells based on the mean of nearby valid values, ensuring spatial continuity across depth layers and near coastal regions.

## Acknowledgments

This work was conducted as part of my ESA Living Planet Fellowship at the University of Oxford under the [SLAM DUNK](https://eo4society.esa.int/projects/slam-dunk/) project.
