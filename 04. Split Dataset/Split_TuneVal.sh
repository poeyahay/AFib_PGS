#### Splitting the biobank dataset into a 30% tuning and 70% validation set! ####

#####################################################################################################################################

### Required files ###

## patient_info.csv ## is a dataset containing, at least, the following information:
# individual IDs (IID), 
# ancestry predictions (e.g. eur/amr/afr/sas/eas)
# sex at birth (1 = male, 0 = female); change this if you think female should be 1.
# available electronic health record data (1 = yes, 0 = no)

## AF_cases.csv ## a separate file containing only one column with the IIDs of atrial fibrillation (AF) cases

#####################################################################################################################################


## 1 ## Create a pre-tuning file

# Print necessary columns (IID, ancestry_pred, sex_at_birth, has_ehr_data)
awk 'BEGIN {FS=OFS=","} NR>1 {print $1,$2,$3,$4}' patient_info.csv > Afib_patient_info_pre.csv

# Keep only the lines with 1 in the has_ehr_data column, and print only the first 3 columns
awk 'BEGIN {FS=OFS=","} NR==1 {print $1,$2,$3; next} $4 == 1 {print $1,$2,$3}' Afib_patient_info_pre.csv > Afib_patient_info_pre_EHRonly.csv

# Change sex_at_birth column so that Female: 0, Male: 1, else: NA
awk 'BEGIN {FS=OFS=","}     # input (FS) and output (OFS) field separator is a comma
 NR==1 {print $0; next}     # at the 1st line/header line (NR==1), print text the same (print $0) and move to next line
 {if ($3 == "Female") $3 = 0; else if ($3 == "Male") $3 = 1; else $3 = "NA"; print $0}' Afib_patient_info_pre_EHRonly.csv > Afib_patient_info_Sex.csv
# Exclude all lines that have NA present in the sex_at_birth column
awk -F, 'BEGIN {OFS=","} NR==1 || ($3 != "NA") {print $1,$2}' Afib_patient_info_Sex.csv > Afib_patient_info_Sex_noNA.csv

## Create pre-tuning file with the columns: FID (=Family ID), IID, pheno (1 = case, 0 = control), ancestry_pred
awk 'BEGIN {FS=OFS=","}
 NR==FNR {cases[$1]; next}  # For 1st file (AF_Cases.csv), store each IID in the array 'cases'
 {print 0,$1,($1 in cases ? 1 : 0),$2}' AF_Cases.csv Afib_patient_info_Sex_noNA.csv > AF_preTune_file.csv  # print '1' if $1 of ALL_Cases_Controls.csv is in 'cases', otherwise print '0'


#####################################################################################################################################


## 2 ##  Create pheno file (required for Multi-tool input!)

# Set Final Results path
pathFINAL='/path/to/Tune_Test/FINAL/'

# Print FID, IID, pheno to create the pheno file
awk -F, 'BEGIN {OFS=","} {print $1,$2,$3}' AF_preTune_file.csv > ${pathFINAL}pheno.csv


#####################################################################################################################################


## 3 ##  Split dataset into a 30% tuning and 70% validation set!

# Shuffle rows randomly
shuf AF_preTune_file.csv > shuf_AF_preTune.csv

# Take the first 30% of the shuffled file
head -n $(awk "BEGIN {print int(0.3 * $(wc -l < shuf_AF_preTune.csv))}") shuf_AF_preTune.csv > AF_Tune_Check_File.csv
# How it works: nr. of lines counted with 'wc -l' is multiplied by 0.3, and of that the integer is taken


#####################################################################################################################################


## 4 ##  Create the FINAL tuning file! (also required for Multi-tool input!)

# Set Final Results path
pathFINAL='/path/to/Tune_Test/FINAL/'

# Print only the first two columns (FID, IID) to create the tuning file
cut -d',' -f1,2 AF_Tune_Check_File.csv > ${pathFINAL}tuneid.csv


## If needed: Make an ancestry-specific tune file
# Here an example for east asian (eas) ancestry
awk -F, 'BEGIN {OFS=","} $4 == "eas" {print $1,$2}' AF_Tune_Check_File.csv > ${pathFINAL}tuneid_eas.csv


#####################################################################################################################################


## 5 ##  Gather information about the Tune set

## List the cases/controls of AF for each ancestry in the Tune set!
# Change the populations (POPs) as needed
for POP in eur amr afr sas eas mid oth; do
    controls_pop=$(awk -F, -v pop="$POP" '$4 == pop && $3 == 0 {count++} END {print count}' AF_Tune_Check_File.csv)
    cases_pop=$(awk -F, -v pop="$POP" '$4 == pop && $3 == 1 {count++} END {print count}' AF_Tune_Check_File.csv)
    echo "# $POP: $cases_pop/$controls_pop"
done


#####################################################################################################################################


## 6 ##  Calculate AF prevalence in the entire dataset (needed for Liability R2 calculation later on !!)

## Calculate prevalence of AF for each ancestry
# Change the populations (POPs) as needed
for POP in eur amr afr sas eas mid oth; do
    total_pop=$(awk -F, -v pop="$POP" '$4 == pop {count++} END {print count}' AF_preTune_file.csv)
    cases_pop=$(awk -F, -v pop="$POP" '$4 == pop && $3 == 1 {count++} END {print count}' AF_preTune_file.csv)
    if [ "$total_pop" -gt 0 ]; then
        prevalence=$(awk "BEGIN {print ($cases_pop / $total_pop)}")
        echo "$POP prevalence of AF: $prevalence"
    else
        echo "$POP prevalence of AF: No data available"
    fi
done