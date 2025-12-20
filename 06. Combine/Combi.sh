### Script to combine the trait-specific PGSs into a combined multi-trait PGS, using the weights from the adapted multi-tool ###

## 1 ##  Remove first and last lines of the unscaled regression coefficient files (obtained from the output of the adapted Multi tool)
for POP in EUR AFR AMR SAS EAS; do
    input_file="Mult_t_${POP}.unscaled.regcoef.csv"
    tmp_file="Mult_t_${POP}.unscaled.regcoef.tmp"
    # Delete first and last line
    sed '1d;$d' "$input_file" > "$tmp_file"
    mv "$tmp_file" "$input_file"
done

## 2 ##  Create the combined multi-trait PGS!
nano Combi.sh
#Paste the text below

#!/bin/bash
#SBATCH --partition=xxx
#SBATCH --job-name=Combi
#SBATCH --output=Combi.out
#SBATCH --error=Combi.err
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30GB

## List of traits and corresponding score files (Format: CPRA SNP A1 BETA)
traits=(AF HF BMI Height CAD SBP DCM PR)
score_files=(
    /path/to/input/score/files/AF_SBayesRC_Score_File.txt
    /path/to/input/score/files/HF_SBayesRC_Score_File.txt
    /path/to/input/score/files/BMI_SBayesRC_Score_File.txt
    /path/to/input/score/files/Height_SBayesRC_Score_File.txt
    /path/to/input/score/files/CAD_SBayesRC_Score_File.txt
    /path/to/input/score/files/SBP_SBayesRC_Score_File.txt
    /path/to/input/score/files/DCM_SBayesRC_Score_File.txt
    /path/to/input/score/files/PR_SBayesRC_Score_File.txt
)

for POP in EUR AFR AMR SAS EAS; do
    # Create temporary (.tmp) files, for each trait, with BETA column multiplied by the weight (from the unscaled regcoef file)
    for i in "${!traits[@]}"; do
        trait=${traits[$i]} # Set current trait
        score_file=${score_files[$i]} # Set current score file
        weight=$(awk -F, -v t="$trait" 'NR>1 && $1==t {print $2}' Mult_t_${POP}.unscaled.regcoef.csv) # Get weight for current trait
        awk -v w="$weight" 'NR>1 {OFS="\t"; $4=$4*w; print $1,$2,$3,$4}' "$score_file" > "${trait}_weighted.tmp" # Create beta*weight tmp file for current trait
    done

    # Dynamically collect all *_weighted.tmp files for merging
    weighted_files=(*_weighted.tmp)
    num_files=${#weighted_files[@]}
    
    # Only sum the betas of the files if rsID ($2) and A1 ($3) match
    awk -v n="$num_files" '
        FNR==1 {file++}
        {
            key = $2 FS $3
            beta[file, key] = $4
            count[key]++  # This will be equal to 8 if key is present in all files
            if (!(key in snp_info)) snp_info[key] = $1 FS $2 FS $3  # Store Markername, SNP, A1 from the 1st score file!
        }
        END {
            for (k in snp_info) {    # k will be the key (rsID and A1)
                if (count[k] == n) { # Only do next part if key is present in all files
                    sum = 0
                    for (i = 1; i <= n; i++) {
                        sum += beta[i, k]  # Sum betas for the current key in all 8 files
                    }
                    print snp_info[k], sum
                }
            }
        }
    ' "${weighted_files[@]}" > Mult_t_${POP}_SBayesRC_Score_File.txt
    
    # Sort by CPRA (chr:pos:ref:alt) column ($1)
    sort -k1,1 Mult_t_${POP}_SBayesRC_Score_File.txt -o Mult_t_${POP}_SBayesRC_Score_File.txt

    # Add headers back to the combined score file
    sed -i '1i CPRA\tSNP\tA1\tBETA' Mult_t_${POP}_SBayesRC_Score_File.txt

    # Cleanup
    rm *_weighted.tmp
done
#Save file with CTRL + X


#Run sumbmission job with:
sbatch Combi.sh

#View submission job with:
squeue -u username