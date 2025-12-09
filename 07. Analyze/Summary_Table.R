### Summary Table Helper Function ###

## 1 ##  Run this function before running Analyze_metrics.R
summary_table <- data.frame() # Create an empty dataframe outside of the function

sum_table <- function(n, PGS, population) {
  summary_table[n, "Cohort"] <- population
  summary_table[n, "PGS"] <- PGS
  summary_table[n, "Cases"] <- cases
  summary_table[n, "Total"] <- total
  summary_table[n, "Beta.full"] <- logOR_full
  summary_table[n, "SE.full"] <- se_full
  summary_table[n, "P.full"] <- if (p_full == "0e+00") {"<1.00E-300"} else {p_full}
  summary_table[n, "OR.full"] <- OR_full
  summary_table[n, "CI.L.OR.full"] <- ci_full[1]
  summary_table[n, "CI.H.OR.full"] <- ci_full[2]
  summary_table[n, "AUC.pgs"] <- round(auc_pgs, digits = 3)
  summary_table[n, "CI.L.AUC.pgs"] <- round(ci_auc_pgs[1], digits = 3)
  summary_table[n, "CI.H.AUC.pgs"] <- round(ci_auc_pgs[3], digits = 3)
  summary_table[n, "AUPRC.pgs"] <- round(auprc_pgs, digits = 3)
  summary_table[n, "ngk_R2_delta_o_resid"] <- round(R2_ngk_delta_over_residualR2, digits = 3)
  summary_table[n, "liab_R2_delta_o_resid"] <- round(R2_liab_delta_over_residualR2, digits = 3)
  
  return(summary_table)
}


####################################################################################################


## 2 ##  Run this, after running Analyze_metrics.R, to save the resulting summary table as .CSV file
write.csv(summary_table, file = "/path/to/sumtables/sumtable.csv", row.names = FALSE, quote = FALSE)