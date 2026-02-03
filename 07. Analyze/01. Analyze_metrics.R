#' @title: Analysis script, to analyze polygenic scores and extract performance metrics.
#' @dependencies: dplyr_1.1.4, data.table_1.17.8, pROC_1.19.0.1, PRROC_1.4, fmsb_0.7.6, ggplot2_4.0.0
#' @license: GPL-3.0 License
#' @author: Poeya Haydarlou

## First run helper functions: LiabR2_func.R & Summary_Table.R


# Inititate row number (for summary table function)
rownr <- 1
# TRUE excludes individuals from Massachusetts
no_MA <- FALSE
# TRUE excludes individuals affiliated with Veteran affairs
no_VA <- FALSE


# Define validation set ancestry/population (POP) & polygenic score (PGS) combinations!
POP_list <- list(
  EUR = c("PGS1", "PGS2", "PGS3"),
  AMR = c("PGS1", "PGS2", "PGS3"),
  AFR = c("PGS1", "PGS2", "PGS3"),
  SAS = c("PGS1", "PGS2", "PGS3"),
  EAS = c("PGS1", "PGS2", "PGS3")
)

# AF prevalence: calculated in the All of Us dataset (see Split_TuneVal.sh script; step 6)
prevalence_list <- list(
  EUR = 0.089,  # European
  AMR = 0.036, # Admixed American
  AFR = 0.047,  # African
  SAS = 0.023,  # South Asian
  EAS = 0.029  # East Asian
)

# Load necessary packages
library(dplyr)
library(data.table)

## Loop through POPs and corresponding PGSs ##
for (POP in names(POP_list)) {
 for (PGS in POP_list[[POP]]) {

  ## Read your dataset (Replace 'PGS_Dataset.csv' with your dataset file)
  df <- fread("/path/to/data/PGS_Dataset.csv")

  # Ensure variables are correctly formatted
  df$case_control <- as.factor(df$case_control)  # Convert case/control to a factor
  df$sex_at_birth <- as.factor(df$sex_at_birth)  # Convert sex to a factor


  ## Correct for the first 20 Principal Components (PCs) to account for population structure
  # Fit linear regression model of the Principal Components (PCs)
  PCs <- paste0("PC", 1:20) # Define the PCs
  formula <- reformulate(termlabels = PCs, response = as.name(PGS)) # Dynamically create the formula using reformulate
  PC_model <- lm(formula, data = df) # Fit lineair regr. model

  # Extract residuals
  df$PGS_residualized <- resid(PC_model)

  # Standardize PGS (creates extra column: PGS_corrected)
  df$PGS_corrected <- scale(df$PGS_residualized)  # Mean = 0, SD = 1 


  ## Extract ancestry (e.g. EUR/AFR)
  pop_iids <- fread(paste0("/path/to/data/", POP, "_IIDs.csv"))
  df <- df[df$IID %in% pop_iids$IID, ] # , ] → Keeps all columns

  ## Exclude individuals from Massachusetts (if no_MA = TRUE)
  if (no_MA) { df <- df[df$from_MA == 0, ] }

  ## Exclude individuals with Veteran Affairs (if no_VA = TRUE)
  if (no_VA) { df <- df[df$has_VA == 0, ] }


  ## Create logistic regression models!
  model_base <- glm(case_control ~ age + sex_at_birth, data = df, family = binomial)   # Base model (age + sex)
  model_full <- glm(case_control ~ age + sex_at_birth + PGS_corrected, data = df, family = binomial)  # Full model (age + sex + PGS)
  model_pgs <- glm(case_control ~ PGS_corrected, data = df, family = binomial)  # PGS-only model


  ### Create variables for the final summary table:

  ## Number of Total, Cases and Controls
  cases <- sum(df$case_control == 1, na.rm = TRUE)
  control <- sum(df$case_control == 0, na.rm = TRUE)
  total <- cases + control

  ## Extract performance metrics:
  # logOR (Beta), standard error (SE), P-value (P), Odds Ratio (OR), and Confidence Intervals (CI)

  # Full Model
  sum_model_full <- summary(model_full)
  logOR_full <- round(sum_model_full$coefficients["PGS_corrected", "Estimate"], digits = 3)
  se_full <- round(sum_model_full$coefficients["PGS_corrected", "Std. Error"], digits = 3)
  p_full <- format(sum_model_full$coefficients["PGS_corrected", "Pr(>|z|)"], scientific = TRUE, digits = 3)
  OR_full <- round(exp(logOR_full), digits =2)
  ci_full <- round(exp(confint(model_full)["PGS_corrected", ]), digits = 2)
  # PGS-only Model
  sum_model_pgs <- summary(model_pgs)
  logOR_pgs <- round(sum_model_pgs$coefficients["PGS_corrected", "Estimate"], digits = 3)
  se_pgs <- round(sum_model_pgs$coefficients["PGS_corrected", "Std. Error"], digits = 3)
  p_pgs <- format(sum_model_pgs$coefficients["PGS_corrected", "Pr(>|z|)"], scientific = TRUE, digits = 3)
  OR_pgs <- round(exp(logOR_pgs), digits =2)
  ci_pgs <- round(exp(confint(model_pgs)["PGS_corrected", ]), digits = 2)


  ## Extract performance metrics: 
  # Area under the receiver operator curve (AUROC) & Area under the precision-recall curve (AUPRC)

  # Load necessary libraries
  library(pROC)
  library(PRROC)
  library(fmsb)

  ## Compute AUROC
  suppressMessages({
   # predict() uses the parameters of the logregr. model to predict AF
   df$pred_val_base <- predict(model_base, newdata = df)
   df$pred_val_full <- predict(model_full, newdata = df)
   df$pred_val_pgs <- predict(model_pgs, newdata = df)
   
   # Create the receiver operator curve (ROC)
   roc_base <- pROC::roc(data=df, response=case_control, predictor=pred_val_base)
   roc_full <- pROC::roc(data=df, response=case_control, predictor=pred_val_full)
   roc_pgs <- pROC::roc(data=df, response=case_control, predictor=pred_val_pgs)
      
   # Compute area under the curve (of the ROC)
   auc_base <- auc(roc_base)  # AUROC of age + sex
   auc_full <- auc(roc_full)  # AUROC of age + sex + PGS
   auc_pgs <- auc(roc_pgs)  # AUROC of PGS-only model
   delta_auc <- auc_full - auc_base # calculate delta AUROC

   # Compute confidence intervals for AUROC
   ci_auc_full <- ci.auc(roc_full)
   ci_auc_pgs <- ci.auc(roc_pgs)
  })

  ## Compute AUPRC
  auprc_full <- pr.curve(scores.class0 = fitted(model_full)[df$case_control == 1], 
               scores.class1 = fitted(model_full)[df$case_control == 0], 
               curve = TRUE)
  auprc_pgs <- pr.curve(scores.class0 = fitted(model_pgs)[df$case_control == 1], 
              scores.class1 = fitted(model_pgs)[df$case_control == 0], 
              curve = TRUE)

  # Extract AUPRC values
  auprc_full <- auprc_full$auc.integral
  auprc_pgs <- auprc_pgs$auc.integral


  ## Extract performance metrics: 
  # Nagelkerke's R2 & Liability R2

  ## Compute Nagelkerke's R2 for the models
  R2_ngk_full <- NagelkerkeR2(model_full)$R2
  R2_ngk_base <- NagelkerkeR2(model_base)$R2
  R2_ngk_delta <- R2_ngk_full - R2_ngk_base
  R2_ngk_delta_over_residualR2 <- R2_ngk_delta / (1 - R2_ngk_base)
  # ResidualR2 = '1 - R2_ngk_base' = the proportion of variance that cannot be explained by the base model
  # R2_ngk_delta_over_residualR2 = the proportion of variance that the PGS can explain, but the base model cannot explain

  ## Compute liability R2 (with help of LiabR2_func.R)
  liab_r2_res <- liability_scale_R2_calc(
    x = "PGS_corrected",
    y = "case_control",
    df = df,
    covar_list = c("age", "sex_at_birth"),
    K = prevalence_list[[POP]]
  )

  # Extract the liability R2 variables
  R2_liab_full <- liab_r2_res[2]
  R2_liab_delta <- liab_r2_res[3]
  R2_liab_delta_over_residualR2 <- liab_r2_res[4]


  ## Optional: Uncomment to create a PGS density plot that differentiates between cases and controls
  #Load necessary libraries
  #library("ggplot2")
  #plot <- ggplot(df, aes(x = PGS_corrected, fill = case_control)) +  # aes = aesthetics
      #geom_density(alpha = 0.5) +  # alpha = 0.5 -> transparency of the fill color is half
      #geom_vline(data = subset(df, case_control == 0),
                 #aes(xintercept = mean(PGS_corrected)),
                 #color = "grey90", linetype = "dashed") +
      #geom_vline(data = subset(df, case_control == 1),
                 #aes(xintercept = mean(PGS_corrected)),
                 #color = "#8B0000", linetype = "dashed") +
      #labs(  # labs = labels
          #title = paste0("SBayesRC Density Plot of ", PGS, " PGS (& AF cases)"),
          #x = "Polygenic Score",  # Updated x-axis label
          #y = "Density",
          #fill = "Cohort"  # Updated legend title
      #) +
      #theme_classic() + # gives a more minimal/clearer look
      #scale_fill_manual(
          #values = c("0" = "grey90", "1" = "#8B0000"),
          #labels = c("0" = "General\npopulation", "1" = "AF")  # Updated legend labels
      #) +
      #theme(
          #axis.line = element_line(linewidth = 0.9),  # Makes the x and y axis lines thicker
          #axis.title = element_text(size = 13),  # Makes x-axis and y-axis labels larger
          #legend.position = c(0.05, 0.9),  # Moves the legend to the top-left corner
          #legend.justification = c(0, 1),  # Aligns the legend to the top-left
          #legend.text = element_text(size = 9),  # Makes the legend text larger
          #legend.title = element_text(size = 11),  # Makes the legend title larger
          #legend.key.size = unit(0.7, "cm")  # Adjusts the size of the legend key to keep the box compact
      #)
  # Display the plot
  #print(plot)

  # Save the PGS density plot as a PDF file
  #if (PGS == "PGS1") {ggsave(file.path("/path/to/density_plots/", paste0("AF_", PGS, ".pdf")), plot, width = 6, height = 5, device = "pdf", bg = "transparent")}


  ## Save the performance metrics in a summary table (row number, polygenic score, population)
  # With help of Summary_Table.R 
  summary_table <- sum_table(rownr, PGS, POP)
  print(summary_table)

  rownr <- rownr + 1 # Increment row number for the next iteration
 }
}
