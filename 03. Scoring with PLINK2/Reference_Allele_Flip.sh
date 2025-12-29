### Flip the reference and alternate alleles of the PGS file to match PLINK2 pvar files of your (AoU) dataset ###

####################################################################################################


## 1 ##  Create a merged reference file

## Concatenate the ID column ($3) of the .pvar files for each chromosome into one merged file
# ID column: contains CPRA format (chr:pos:ref:alt or 10:11121:G:A)
for chr in {1..22} X Y; do
    cut -f3 /path/to/pfiles/pfile_${chr}.pvar
done > pfile_merged_pvar.txt


####################################################################################################


## 2 ##  Identify PGS variants that do not match the reference file and flip alleles!

## Save all non-matching variants (+ SNP, A1 & BETA) in a separate file
for trait in AF; do
# Use at least 4 CPUs, 15 RAM
awk 'BEGIN {OFS="\t"}
NR==FNR{if(NR>1) {
 a[$1]; next}}            # Save the values of pfile_merged_pvar.txt into an array a[]
FNR>1 && !($1 in a) {
 split($1, CPRA, ":");    # Split CPRA column of PGS file into components
 print CPRA[1]":"CPRA[2]":"CPRA[4]":"CPRA[3], $2, $3, $4}' \    # REMOVE THIS COMMENT: Print all non-matching variants with flipped alleles (+ SNP, A1 & BETA columns)
/path/to/pfiles/pfile_merged_pvar.txt \
/path/to/scripts/${trait}_SBayesRC_Score_File.txt \
> /path/to/scripts/${trait}_non_matching_variants.txt
done


####################################################################################################


## 3 ##  Append the non-matching and flipped variants to the original PGS file

for trait in AF; do
cat ${trait}_non_matching_variants.txt >> ${trait}_SBayesRC_Score_File.txt
done