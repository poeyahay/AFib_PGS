## Table of Contents
- [Overview](#overview)
- [SBayesRC-multi and Adapted multi tool](#sbayesrc-multi-and-adapted-multi-tool)
- [METAL execution scripts](#metal-execution-scripts)
- [SBayesRC execution script](#sbayesrc-execution-script)
- [Citation](#citation)

## Overview

This GitHub repository contains scripts demonstrating how GWAS meta-analysis was performed using [**METAL**](https://github.com/poeyahay/AFib_PGS/tree/main/METAL), how polygenic scores (PGSs) were created using [**SBayesRC**](https://github.com/poeyahay/AFib_PGS/blob/main/SBayesRC/SBRC_Run.sh), and how multiple polygenic scoring files were combined using the [**SBayesRC-multi tool**](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/SBRCmulti.R) (handles two PGS input files) and the [**Adapted multi tool**](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/Multi_Tool.R) (handles more than two PGS input files).  

The scripts are related to the manuscript:

*“Multi-trait polygenic risk scores improve genomic prediction of atrial fibrillation across diverse ancestries”*,

which was recently submitted (preprint DOI: [https://doi.org/10.21203/rs.3.rs-7713077/v1](https://doi.org/10.21203/rs.3.rs-7713077/v1)).

## SBayesRC-multi and Adapted multi tool

These functions combine multiple polygenic score files into a single multi-PGS score.

[**SBayesRC-multi tool**](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/SBRCmulti.R)
- Handles two PGS input files.

[**Adapted multi tool**](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/Multi_Tool.R)
- Handles more than two PGS input files.

#### For both multi tools:
- **Usage instructions**
  - Each script begins with a clear description of the required input formats and an example of how to call the function.
- **Software requirements:**
  - This tool has been tested on RStudio (v4.5.0) and dependencies include data.table_1.17.0 and fmsb_0.7.6.
- **Installation:**
  - No installation is needed, just run the code in Rstudio, and apply the function afterwards.
- **License:**
  - [GNU General Public License](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/LICENSE)

#### Input (dummy) data:
- [PRS1](https://drive.google.com/file/d/1pidftXIenQ5NYy_IrmX9hccsf5veX1zl/view?usp=drive_link)
- [PRS2](https://drive.google.com/file/d/1iez_AQV9bQFqzHDeqAuXD_DXbqGoiVvG/view?usp=drive_link)
- [PRS3](https://drive.google.com/file/d/1nqV3_YAlwzFHC2hai1f9V0KDqviiN0_5/view?usp=drive_link)
- [tuneid](https://drive.google.com/file/d/16USsSVtZHhk9gb-vna6mYn3ngzLIPs86/view?usp=drive_link)
- [pheno](https://drive.google.com/file/d/1Atuo9NX-wUJqkDRG4uRPLU7hBc5lKAAz/view?usp=drive_link)
- [keepid](https://drive.google.com/file/d/1cFKB3VXLg72zKoeIh6zBSckz7Z1lKHwq/view?usp=drive_link)

**Of note:** The multi functions use logistic regression and are therefore suitable for binary outcomes only. However, the script can be adapted to perform linear regression and calculate the ordinary R² from the linear model (instead of Nagelkerke’s R²).

Example usage of the multi functions is given at the beginning of each multi script.

## METAL execution scripts
Execution scripts on how GWAS meta-analysis was performed for:
- [Atrial Fibrillation GWAS data](https://github.com/poeyahay/AFib_PGS/blob/main/METAL/AFGen%2BMVP.sh)
- [Systolic Blood Pressure GWAS data](https://github.com/poeyahay/AFib_PGS/blob/main/METAL/SBP_trait.sh)

#### Resources and Runtime:
- 16 CPUs
- ~70 GB of memory
- Typical runtime of ~4.5 hours

These scripts were run on a high-performance computing (HPC) cluster, after installation of METAL [(v2011-03-25)](https://csg.sph.umich.edu/abecasis/metal/download/)

## SBayesRC execution script
[Execution script](https://github.com/poeyahay/AFib_PGS/blob/main/SBayesRC/SBRC_Run.sh) on how we created our polygenic scores using SBayesRC.

#### Resources and Runtime:
- 8 CPUs
- ~10 GB of memory
- Typical runtime of ~5-10 minutes

This script was also run on a HPC cluster, after installation of the SBayesRC software [(v0.2.6)](https://github.com/zhilizheng/SBayesRC)

## Citation
**If you use these scripts, please cite the following manuscript:**

*Haydarlou, P., et al.* “Multi-trait polygenic risk scores improve genomic prediction of atrial fibrillation across diverse ancestries.” (under review). Preprint DOI: [10.21203/rs.3.rs-7713077/v1](https://doi.org/10.21203/rs.3.rs-7713077/v1)
