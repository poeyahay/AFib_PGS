### Merge the output files together for each chromosome (to create ${trait}_Scored_File.txt) ###

# Go to working directory
cd /path/to/results

## Merge!
for trait in AF HF BMI Height CAD SBP DCM PR; do
  # Create an empty file to store the merged results
  > ${trait}_merged_PRS_interim.txt

  # Create an interim file in which all chromosome files are concatenated
  for i in {1..22} X Y; do
    awk 'NR > 1 {print $1, $2}' ${trait}_Scored_File_chr${i}.sscore >> ${trait}_merged_PRS_interim.txt
  done

  # Sum scores based on matching IIDs ($1 = IID, $2 = SCORE1_SUM)
  awk '{sum[$1] += $2} END {for (id in sum) print id, sum[id]}' ${trait}_merged_PRS_interim.txt > ${trait}_Scored_File.txt

  # Add headers
  sed -i '1i IID\tSCORE1_SUM' ${trait}_Scored_File.txt

  # Remove the intermediate file
  rm ${trait}_merged_PRS_interim.txt
done


## Convert to CSV (needed for Multi tool input)
for trait in AF HF BMI Height CAD SBP DCM PR; do
tr -s ' \t' ',' < ${trait}_Scored_File.txt > ${trait}_Scored_File.csv
done


# Remove the per-chromosome scored files
for trait in AF HF BMI Height CAD SBP DCM PR; do
rm ${trait}_Scored_File_chr*.sscore
done