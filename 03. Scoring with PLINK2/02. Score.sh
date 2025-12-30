### Scoring the AF trait PGS in PLINK2 per chromosome ###
# --pfile: add the path to the genotype files in pgen/pvar/psam format
# --score: add the path to the PGS score file (columns: CPRA (=chr:pos:ref:alt), SNP, A1, BETA)
# --out: add the path and filename prefix for the output file

# Score the first 15 chromosomes
# Use 16 CPUs; 60 RAM
for i in {1..15}; do
    plink2 --pfile /path/to/pfiles/pfile_chr${i} \
           --score /path/to/scripts/AF_SBayesRC_Score_File.txt 1 3 4 header cols=scoresums \
           --out /path/to/results/AF_Scored_File_chr${i} \
            --threads 1 &
done
wait

# Score the last seven chromosomes
# Use 8 CPUs; 30 RAM
for i in {16..22}; do
    plink2 --pfile /path/to/pfiles/pfile_chr${i} \
           --score /path/to/scripts/AF_SBayesRC_Score_File.txt 1 3 4 header cols=scoresums \
           --out /path/to/results/AF_Scored_File_chr${i} \
            --threads 1 &
done
wait