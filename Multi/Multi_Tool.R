#' @title Multi-tool: calculate the optimally weighted PRS using multiple PRS sets.
#' @note Adapted from: https://github.com/zhilizheng/SBayesRC (GPL-3.0 License)
#' @dependencies data.table_1.17.0, fmsb_0.7.6
#' @author: Poeya Haydarlou

# Example Usage:
# 1. Assign prs input file paths (IID SCORE1_SUM, with header)
PRS1 = /path/to/PRS1.csv
PRS2 = /path/to/PRS2.csv
PRS3 = /path/to/PRS3.csv
# 2. Assign function parameters
prs_files = c(PRS1, PRS2, PRS3) # paths to the prs files (comma separated!)
prs_names = c("PRS1", "PRS2", "PRS3") # names of the prs files
outPrefix = "/path/to/output/Out" # output path -> Out.score.txt & Out.weight.tsv
tuneid = "/path/to/tuneid.csv" # path to tuning sample ID file (FID IID; no header; csv)
pheno = "/path/to/pheno.csv" # path to phenotype file (FID IID pheno; no header; csv)
keepid = "/path/to/keepid.csv" # path to sample IDs (FID IID) to be kept. default is "": use all samples
log2file = TRUE # default is FALSE. TRUE: write to log file; FALSE: print to terminal
# 3. Apply the function
Multi(prs_files, prs_names, outPrefix, tuneid, pheno, keepid, log2file)

# -------------------------------
# **Code for Logger Functions Starts Below** 
# -------------------------------

# Load the logger functions
logger.begin <- function(log2file, logfile){
    if(log2file){
        message("The messages are redirected to ", outPrefix, ".log")
        sink(logfile)
        sink(logfile, type="message")
    }
}
logger.end <- function(log2file, logfile){
    if(log2file){
        sink()
        sink(type="message")
        close(logfile)
    }
}

# -------------------------------
# **Code for Multi Function Starts Below** 
# -------------------------------

# Run the main Multi function
Multi <- function(prs_files, prs_names, outPrefix, tuneid, pheno, keepid = "", log2file = FALSE) {
    message("Running Multi-tool...")
    logfile = file(paste0(outPrefix, ".log"), "wt")
    logger.begin(log2file, logfile)
    if (log2file) {
        message("Running Multi-tool...")
    }

    # Check if prs_names is provided, otherwise assign default names
    if (exists("prs_names") && length(prs_names) == length(prs_files)) {
        prs_names = prs_names
    } else {
        prs_names = paste0("PRS", seq_along(prs_files))
    }

    # Read tuning IDs
    library(data.table)
    dt.tune = fread(tuneid, head = FALSE, sep = ",")
    setnames(dt.tune, c("FID", "IID"))
    message(nrow(dt.tune), " tuning samples")

    # Check if all PRS files exist
    for (prs in prs_files) {
        if (!file.exists(prs)) {
            stop("PRS file doesn't exist: ", prs)
        }
    }

    # Read and process all PRS files
    prs_list = list()
    for (i in seq_along(prs_files)) {
        prs_file = prs_files[i]
        dt.prs = fread(prs_file, sep = ",")[is.finite(SCORE1_SUM)]
        setnames(dt.prs, "SCORE1_SUM", paste0("SCORE1_SUM.", i))
        message(nrow(dt.prs), " samples in ", prs_names[i], " file")
        prs_list[[i]] = dt.prs
    }

    # Filter PRS files based on keepid if provided
    if (file.exists(keepid)) {
        keep.id = fread(keepid, head = FALSE)
        message(nrow(keep.id), " samples in keepid")
        for (i in seq_along(prs_list)) {
            idx = match(keep.id[[2]], prs_list[[i]]$IID)
            prs_list[[i]] = prs_list[[i]][idx[is.finite(idx)]]
            message(nrow(prs_list[[i]]), " samples remained in ", prs_names[i], " file after merging with keepid")
        }
    }

    # Merge all PRS files by IID
    dt.prs = Reduce(function(x, y) merge(x, y, by = "IID", all = FALSE), prs_list)
    message(nrow(dt.prs), " common samples across all PRS files")

    # Read phenotype file
    dt.pheno.raw = fread(pheno, sep = ",")
    setnames(dt.pheno.raw, c("FID", "IID", "pheno"))
    dt.pheno = dt.pheno.raw[is.finite(pheno)]
    message(nrow(dt.pheno), " samples in phenotype")
    dt.prs.all = merge(dt.prs, dt.pheno[, .(IID, pheno)], by = "IID")
    message(nrow(dt.prs.all), " samples after merging all data")

    # Filter tuning samples
    dt.prs.all.tune = dt.prs.all[IID %in% dt.tune$IID]
    message(nrow(dt.prs.all.tune), " valid tuning samples")

    # Tuning weights
    message("Tuning weights...")
    formula = as.formula(paste("pheno ~", paste(paste0("SCORE1_SUM.", seq_along(prs_files)), collapse = " + ")))
    model = glm(formula, data = dt.prs.all.tune, family = binomial)
    dt.prs.all[, SCORE := predict(model, dt.prs.all[, paste0("SCORE1_SUM.", seq_along(prs_files)), with = FALSE])]
    fwrite(dt.prs.all[, .(IID, SCORE)], file = paste0(outPrefix, ".score.txt"), sep = "\t", na = "NA", quote = FALSE)

    # Output weights and R-squared values
    coef1 = summary(model)$coefficients[, 1]
    message(paste0("intercept: ", coef1[1]))
    for (i in seq_along(prs_files)) {
        message(paste0("weight_", prs_names[i], ": ", coef1[i + 1]))
    }

    library(fmsb)
    dt.prs.all.tune2 = dt.prs.all[IID %in% dt.tune$IID]
    r_values = sapply(seq_along(prs_files), function(i) {
        NagelkerkeR2(glm(as.formula(paste("pheno ~ SCORE1_SUM.", i, sep = "")), data = dt.prs.all.tune2, family = binomial))$R2
    })
    r_weighted = NagelkerkeR2(glm(pheno ~ SCORE, data = dt.prs.all.tune2, family = binomial))$R2

    for (i in seq_along(r_values)) {
        message(paste0("Ngk-R2 for ", prs_names[i], " PRS in tuning samples: ", r_values[i]))
    }
    message("Ngk-R2 for weighted PRS in tuning samples: ", r_weighted)
    message("Note: those R-squared values were calculated in tuning samples, please don't report as prediction accuracy!")
    message("Use the weighted PRS in ", outPrefix, ".score.txt and exclude the tuning samples to check the prediction accuracy.")
    if (r_weighted < max(r_values)) {
        warning("Weighted PRS has lower R-squared, the inputs may have problems, please double-check.")
    }

    # Calculate SD for each PRS in the tuning set
    sd_values = sapply(seq_along(prs_files), function(i) {
        sd(dt.prs.all.tune[[paste0("SCORE1_SUM.", i)]], na.rm = TRUE)
    })

    # Prepare data for unscaled regression coefficients
    weights_only <- as.numeric(coef1[-1])
    proportions <- abs(weights_only) / sum(abs(weights_only)) * 100
    regcoef_data = data.table(
        PRS_Name = c(prs_names, "Weighted_PRS"),
        Weight = c(weights_only, NA),
        Proportion = c(proportions, NA),
        Ngk_R2_Tune = c(r_values, r_weighted)
    )

    # Prepare data for mixing weights (weights * SD)
    mixing_weights = weights_only * sd_values
    mixing_proportions = abs(mixing_weights) / sum(abs(mixing_weights)) * 100
    mixing_data = data.table(
        PRS_Name = prs_names,
        Mixing_Weight = mixing_weights,
        Mixing_Proportion = mixing_proportions,
        SD_in_Tune = sd_values
    )

    # Write the CSV files
    regcoef_file = paste0(outPrefix, ".unscaled.regcoef.csv")
    mixing_file = paste0(outPrefix, ".mixing.weights.csv")
    # Unscaled regcoef file
    writeLines(paste0("intercept: ", coef1[1]), con = regcoef_file)
    fwrite(regcoef_data, file = regcoef_file, sep = ",", append = TRUE, col.names = TRUE, quote = FALSE, na = "NA")
    # Mixing weights file
    fwrite(mixing_data, file = mixing_file, sep = ",", col.names = TRUE, quote = FALSE)

    message("Done.")
    logger.end(log2file, logfile)
}