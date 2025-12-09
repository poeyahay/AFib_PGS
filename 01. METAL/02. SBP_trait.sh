for i in SBP; do
metal <<EOF
# Paste the script in METAL
SCHEME STDERR        # Use standard error for inverse variance weighted meta-analysis
MARKER CPRA          # chr:pos:ref:alt format
ALLELE A1 A2         # Effect and alternate alleles
EFFECT b             # Effect size (beta or log(OR))
STDERR se            # Standard error of the effect size
PVALUE p             # p-value of the effect size

FREQ freq            # Provide frequency column name
AVERAGEFREQ ON       # Give average frequency as output column

CUSTOMVARIABLE N            # Make customvariables for N
LABEL N as N                # 1st is output column name, 2nd is input column name

PROCESS /add/your/input/file/path/here/${i}_Shi_metal_input_file.txt     # First GWAS summary statistics file
PROCESS /add/your/input/file/path/here/${i}_MVP_metal_input_file.txt     # Second GWAS summary statistics file

# Output the combined results (the 'space' indicates the prefix and suffix for METAL)
OUTFILE /add/your/output/file/path/here/${i}_meta_analysis_results .tbl

ANALYZE
EOF
done