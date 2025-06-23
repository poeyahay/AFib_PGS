for POP in EUR AMR ALL; do
metal <<EOF
#Paste the script in METAL
SCHEME STDERR       # Use standard error for inverse variance weighted meta-analysis, therefore WEIGHT N_total flag not needed
MARKER Marker_name  # chr:pos:ref:alt format
ALLELE Effect_allele Other_allele  # Effect and alternate alleles
EFFECT Effect_size  # Effect size (beta or log(OR))
STDERR StdErr       # Standard error of the effect size
PVALUE P_value      # p-value for association

FREQ Freq           #Provide frequency column name
AVERAGEFREQ ON      #Give average frequency as output column

CUSTOMVARIABLE N_cases      #Make customvariables for N_cases, N_controls & N_total
LABEL N_cases as N_cases    #1st is output column name, 2nd is input column name
CUSTOMVARIABLE N_controls
LABEL N_controls as N_controls
CUSTOMVARIABLE N_total
LABEL N_total as N_total

PROCESS /add/your/input/file/path/here/AFGen_${POP}_metal_input_file.txt   # First GWAS summary statistics file
PROCESS /add/your/input/file/path/here/MVP_${POP}_metal_input_file.txt     # Second GWAS summary statistics file

# Output the combined results (the 'space' indicates the prefix and suffix for METAL)
OUTFILE /add/your/output/file/path/here/${POP}_meta_analysis_results .tbl

ANALYZE
EOF
done