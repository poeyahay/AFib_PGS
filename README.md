## Overview

This GitHub repository contains scripts demonstrating how GWAS meta-analysis was performed using [**METAL**](https://github.com/poeyahay/AFib_PGS/tree/main/METAL), how polygenic scores were created using [**SBayesRC**](https://github.com/poeyahay/AFib_PGS/blob/main/SBayesRC/SBRC_Run.sh), and how multiple polygenic scoring files were combined using the [**SBayesRC-multi**](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/SBRCmulti.R) tool (handles two PGS input files) and the [**Adapted multi tool**](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/Multi_Tool.R) (handles more than two PGS input files).  

The scripts are related to the manuscript:

*“Multi-trait polygenic risk scores improve genomic prediction of atrial fibrillation across diverse ancestries”*,

which was recently submitted to *Nature Communications* ([https://doi.org/10.21203/rs.3.rs-7713077/v1](https://doi.org/10.21203/rs.3.rs-7713077/v1)).

## SBayesRC-multi and Adapted multi tool
[**SBayesRC-multi**](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/SBRCmulti.R):
- handles two PGS input files
[**Adapted multi tool**](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/Multi_Tool.R):
- handles more than two PGS input files

**For both:**
- **Software requirements:**
  - This tool has been tested on RStudio (v4.5.0) and dependencies include data.table_1.17.0 and fmsb_0.7.6
- **Installation:**
  - No installation is needed, just run the code in Rstudio, and apply the function afterwards.
- **License:**
  - [GNU General Public License](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/LICENSE)

Example usage of the multi functions is given at the beginning of each multi script

## METAL execution scripts
Execution scripts on how GWAS meta-analysis was performed for the:
- [Atrial Fibrillation GWAS data](https://github.com/poeyahay/AFib_PGS/blob/main/METAL/AFGen%2BMVP.sh)
- [Systolic Blood Pressure GWAS data](https://github.com/poeyahay/AFib_PGS/blob/main/METAL/SBP_trait.sh)
**Resources and Runtime:**
- 16 CPUs
- ~70 GB of memory
- Typical runtime of ~4.5 hours

These scripts were run on a high performance computer, after installation of METAL (v2011-03-25) (https://csg.sph.umich.edu/abecasis/metal/download/)

## SBayesRC execution script
[Execution script](https://github.com/poeyahay/AFib_PGS/blob/main/SBayesRC/SBRC_Run.sh) on how we created our polygenic scores using SBayesRC.
Resources and Runtime:**
- 8 CPUs
- ~10 GB of memory
- Typical runtime of ~5-10 minutes

This script was also run on a high performance computer, after installation of the SBayesRC software (v0.2.6) (https://github.com/zhilizheng/SBayesRC)
