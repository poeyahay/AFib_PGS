## Overview

This repository provides a full walkthrough of how we generated our multi-trait polygenic scores (PGSs) related to the manuscript:

*“Multi-trait polygenic risk scores improve genomic prediction of atrial fibrillation across diverse ancestries”*,

Preprint available on PubMed: [https://pmc.ncbi.nlm.nih.gov/articles/PMC12622184/](https://pmc.ncbi.nlm.nih.gov/articles/PMC12622184/).


## Walkthrough
1. [GWAS meta-analysis for AF and SBP using METAL](#gwas-meta-analysis-for-af-and-sbp-using-metal)
2. [Preprocess trait-specific GWAS summary statistics](#preprocess-trait-specific-gwas-summary-statistics)
3. [Run SBayesRC](#run-sbayesrc)
4. [Postprocess SBayesRC output](#postprocess-sbayesrc-output)
5. [Score trait-specific PGSs with PLINK2](#score-trait-specific-pgss-with-plink2)
6. [Split dataset (30% tuning, 70% testing)](#split-dataset-30-tuning-70-testing)
7. [Multi tool functions](#multi-tool-functions)
8. [Generate the final multi-trait PGS file](#generate-the-final-multi-trait-pgs-file)
9. [Score again with PLINK2](#score-again-with-plink2)
10. [Analyze results and extract performance metrics](#analyze-results-and-extract-performance-metrics)

** [Citation](#citation)

## GWAS meta-analysis for AF and SBP using METAL

For the traits atrial fibrillation (AF) and systolic blood pressure (SBP), we performed genome-wide association study (GWAS) meta-analyses using **METAL**.

All pre- and postprocessing steps for METAL are documented in the *Supplementary Materials* of our paper, in the section titled **“Meta-analysis using METAL”**.

Execution scripts for each meta-analysis are available here:
- [Atrial Fibrillation GWAS](https://github.com/poeyahay/AFib_PGS/blob/main/METAL/AFGen%2BMVP.sh)
- [Systolic Blood Pressure GWAS](https://github.com/poeyahay/AFib_PGS/blob/main/METAL/SBP_trait.sh)

#### Resources and Runtime:
- 16 CPUs
- ~70 GB of memory
- Typical runtime of ~4.5 hours

These scripts were run on a high-performance computing (HPC) cluster, after installation of METAL [(v2011-03-25)](https://csg.sph.umich.edu/abecasis/metal/download/)


## Preprocess trait-specific GWAS summary statistics

Preprocessing steps for the trait-specific GWAS summary statistics, before SBayesRC input, are detailed in the *Supplementary Materials* of our paper, within the section **“PGS generation using SBayesRC”** and the subsections *“Input file formatting”* and *“Data conversion and preprocessing.”*


## Run SBayesRC

[Execution script](https://github.com/poeyahay/AFib_PGS/blob/main/SBayesRC/SBRC_Run.sh) on how we created polygenic scoring files using SBayesRC.

#### Resources and Runtime:
- 8 CPUs
- ~10 GB of memory
- Typical runtime of ~5-10 minutes

This script was also run on a HPC cluster, after installation of the SBayesRC software [(v0.2.6)](https://github.com/zhilizheng/SBayesRC)


## Postprocess SBayesRC output

Postprocessing steps for the SBayesRC outputs are detailed in the *Supplementary Materials* of our paper, within the section **“PGS generation using SBayesRC”** and the subsections *“Output processing”* and *“Full alignment with All of Us variants.”*


## Score trait-specific PGSs with PLINK2

The SBayesRC-derived polygenic *scoring* files, containing the columns:
- **CPRA** (chromosome, position, reference allele, alternate allele)
- **SNP** (rsID)
- **A1** (effect/alternate allele)
- **BETA** (effect size)
were scored with **PLINK2** within the All of Us biobank.

Scoring was performed using this [script](https://github.com/poeyahay/AFib_PGS/blob/main/Scoring%20with%20PLINK2/Score.sh), which uses AF as an exemplary trait.

The resulting trait-specific *scored* files were then merged into a single file, containing the summed scores across all chromosomes, and the columns:
- **IID** (individual ID)
- **SCORE1_SUM** (polygenic score per individual)

Merging was performed using the following [script](https://github.com/poeyahay/AFib_PGS/blob/main/Scoring%20with%20PLINK2/Merge.sh) 


## Split dataset (30% tuning, 70% testing)

Before combining the trait-specific *scored* files using the [Multi tool functions](#multi-tool-functions), we split the All of Us biobank dataset into a **30% tuning set** and a **70% testing set** using the following [script](https://github.com/poeyahay/AFib_PGS/blob/main/Split%20Dataset/Split_TuneVal.sh).

This [script](https://github.com/poeyahay/AFib_PGS/blob/main/Split%20Dataset/Split_TuneVal.sh) also generates the **pheno.csv** and **tuneid.csv** files required as input for the Multi tool, and computes the **AF prevalence** in the biobank dataset, which is needed for the liability \(R^2\) calculation used later in the section:  
[Analyze results and extract performance metrics](#analyze-results-and-extract-performance-metrics).


## Multi tool functions

These functions combine multiple polygenic *scored* files into a single multi-PGS *scored* file (IID, SCORE1_SUM).

[**SBayesRC-multi tool**](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/SBRCmulti.R)
- Handles two PGS input files.

[**Adapted multi tool**](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/Multi_Tool.R)
- Handles more than two PGS input files.

#### For both:
- **Usage instructions**
  - Each script begins with a description of the required input formats and an example of how to call the function.
- **Software requirements:**
  - This tool has been tested on RStudio (v4.5.0) and dependencies include data.table_1.17.0 and fmsb_0.7.6.
- **Installation:**
  - No installation is needed, just run the code in Rstudio, and apply the function afterwards.
- **License:**
  - [GNU General Public License](https://github.com/poeyahay/AFib_PGS/blob/main/Multi/LICENSE)

#### Dummy data:
- [PRS1](https://drive.google.com/file/d/1pidftXIenQ5NYy_IrmX9hccsf5veX1zl/view?usp=drive_link)
- [PRS2](https://drive.google.com/file/d/1iez_AQV9bQFqzHDeqAuXD_DXbqGoiVvG/view?usp=drive_link)
- [PRS3](https://drive.google.com/file/d/1nqV3_YAlwzFHC2hai1f9V0KDqviiN0_5/view?usp=drive_link)
- [tuneid](https://drive.google.com/file/d/16USsSVtZHhk9gb-vna6mYn3ngzLIPs86/view?usp=drive_link)
- [pheno](https://drive.google.com/file/d/1Atuo9NX-wUJqkDRG4uRPLU7hBc5lKAAz/view?usp=drive_link)
- [keepid](https://drive.google.com/file/d/1cFKB3VXLg72zKoeIh6zBSckz7Z1lKHwq/view?usp=drive_link)

**Of note:** The multi functions use logistic regression and are therefore suitable for binary outcomes only. However, the script can be adapted to perform linear regression and calculate the ordinary R² from the linear model (instead of Nagelkerke’s R²).


## Generate the final multi-trait PGS file

Next, we used the following [script](https://github.com/poeyahay/AFib_PGS/blob/main/06.%20Combine/Combi.sh) to combine the eight trait-specific polygenic *scoring* files into a single multi-trait *scoring* file (CPRA, SNP, A1, BETA). We did this by multiplying the effect size (BETA) of each SNP within a trait-specific *scoring* file with its unscaled regression coefficient, derived from **.unscaled.regcoef.csv** from the adapted multi-tool output. Therafter, we summed the re-calculated beta's for the SNPs that matched across trait-specific *scoring* files, creating the final multi-PGS *scoring* file.

## Generate the final multi-trait PGS file

We then used the following [script](https://github.com/poeyahay/AFib_PGS/blob/main/06.%20Combine/Combi.sh) to combine the eight trait-specific polygenic *scoring* files into a single multi-trait *scoring* file (CPRA, SNP, A1, BETA).  

For each trait-specific *scoring* file, the SNP-level effect sizes (BETA) were multiplied by that trait’s unscaled regression coefficient, obtained from the **.unscaled.regcoef.csv** output of the adapted Multi tool. SNPs shared across trait-specific files were then matched, and their updated effect sizes were summed. This produced the final combined multi-trait PGS *scoring* file.


## Score again with PLINK2

To [analyze the results and extract performance metrics](#analyze-results-and-extract-performance-metrics), we scored the multi-trait *scoring* file (CPRA, SNP, A1, BETA) [using PLINK2 and then merged the resulting per-chromosome outputs](#score-trait-specific-pgss-with-plink2) again, to produce the multi-trait *scored* file (IID, SCORE1_SUM).


## Analyze results and extract performance metrics

Finally, we used this [script](https://github.com/poeyahay/AFib_PGS/blob/main/07.%20Analyze/Analyze_metrics.R) to fit logistic regression models with the multi-trait PGS as predictor, adjusting for the first 20 principal components as well as age and sex. Performance metrics were then extracted from these models.

Three inputs are needed for the analysis script:
1. **PGS_Dataset.csv** — includes the following columns:  
   - `IID` (individual ID)  
   - `age`  
   - `sex_at_birth` (male = 1, female = 0; flip if you prefer female = 1)  
   - `from_MA` (1 = from Massachusetts, 0 = not)  
   - `has_VA` (1 = has Veterans Affairs affiliation, 0 = not)  
   - `case_control` (1 = AF case, 0 = control)  
   - polygenic *scored* file (PGS per IID)  
   - principal components (`PC1–PC20`)  
   **Important:** Exclude all tuning-set IIDs.

2. **POP_IIDs.csv** files (e.g., `AFR_IIDs.csv`) — each file contains a single column (`IID`) listing individuals belonging to a specific ancestry group. These files are needed for ancestry-specific validation analyses.

3. **Ancestry-specific AF prevalence** within All of Us — computed during step 6 of the [Split_TuneVal.sh](https://github.com/poeyahay/AFib_PGS/blob/main/Split%20Dataset/Split_TuneVal.sh) script and required for liability R² estimation.

#### Dummy data:
- [PGS_Dataset](https://drive.google.com/file/d/1OY-vnxmUq-1l1IdVrqyfd0tksRHKNFYS/view?usp=drive_link)
- [EUR_IIDs](https://drive.google.com/file/d/1R1BBlE3y9Dj2ydpOR5F-Lw_ItL60JVMc/view?usp=drive_link) • [AFR_IIDs](https://drive.google.com/file/d/116KjWQKS8v73sUc2w7lAr3yqJK5b-USU/view?usp=drive_link) • [AMR_IIDs](https://drive.google.com/file/d/1iMVegA0ehEaWJORoB58Xi2U-GiNqBMuI/view?usp=drive_link) • [ASN_IIDs](https://drive.google.com/file/d/1-yQbS7lmcDEEnFZV2R2125Zkgkqz7bo4/view?usp=drive_link)


## Citation
**If you use these scripts, please cite the following:**

*Haydarlou, P., et al.* “Multi-trait polygenic risk scores improve genomic prediction of atrial fibrillation across diverse ancestries.” (under review). Preprint DOI: [10.21203/rs.3.rs-7713077/v1](https://doi.org/10.21203/rs.3.rs-7713077/v1)