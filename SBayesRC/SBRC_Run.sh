#!/bin/bash
#SBATCH --partition=xxx
#SBATCH --job-name=SBayesRC_EUR
#SBATCH --output=SBayesRC_EUR.out
#SBATCH --error=SBayesRC_EUR.err
#SBATCH --time=06:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=80GB

apptainer      # run apptainer on HPC

# docker image address:  zhiliz/sbayesrc
# We use Apptainer (formerly Singularity) as an example
# The users can also use the container in Docker directly with the mapping volumes
# same as the previous example
ma_file="/add/your/input/file/path/here/EUR_AFGenMVP_SBayesRC_input.tsv"      # GWAS summary in COJO format (the only input)
ld_folder="/add/your/LDref/file/path/here/ukbEUR_Imputed"                     # European LD reference (download from "Resources")
annot="/add/your/annotation/file/path/here/annot_baseline2.2.txt"             # Functional annotation (download from "Resources")
out_prefix="/add/your/output/file/path/here/EUR_Meta"                         # Output prefix, e.g. "./test"
threads=16       # Number of CPU cores

# Tidy
apptainer run docker://zhiliz/sbayesrc --ldm-eigen $ld_folder \
    --gwas-summary $ma_file --impute-summary --out ${out_prefix} --threads $threads
# Main: SBayesRC
apptainer run docker://zhiliz/sbayesrc --ldm-eigen $ld_folder \
    --gwas-summary ${out_prefix}.imputed.ma --sbayes RC --annot $annot --out ${out_prefix} \
    --threads $threads

#########################
# PRS
## --geno support both PLINK BED and PGEN format
## test1.txt and test2.txt are weights obtained from SBayesRC
## if only subset SNPs needed in calculation: --extract snp.list
## --keep and --extract are optional flags
# apptainer run docker://zhiliz/sbayesrc --geno test1{CHR} --chr-range 1-22 --score test1.txt --keep keep.id --out prs1
# apptainer run docker://zhiliz/sbayesrc --geno test1{CHR} --chr-range 1-22 --score test2.txt --keep keep.id --out prs2

# SBayesRC-multi
## First: get two PRS from each population with --score
## --keep keep.id is optional flag
# apptainer run docker://zhiliz/sbayesrc  --sbayesrc-multi prs1.score.txt prs2.score.txt --pheno test.pheno --tuneid tune.id --keep keep.id --out weighted_prs