#### Liability R2 Helper Function ####

### Run this function before running Analyze_metrics.R
liability_scale_R2_calc <- function(x, y, df, covar_list, K) {
  
  ## Filter rows with no missing values in y, x, or covariates
  df <- df[!is.na(df[[y]]) & !is.na(df[[x]]) & !apply(df[, ..covar_list, with = FALSE], 1, anyNA), ]
  covars <- paste(covar_list, collapse = ' + ')

  y0 <- as.numeric(as.character(df[[y]]))
  trait <- y0
  
  if (is.na(K)) {K <- table(df[[y]])[["1"]] / nrow(df)}
  ## Population prevalence, assume study prevalence if NA
  ncase <- table(df[[y]])[["1"]]
  ncont <- table(df[[y]])[["0"]]
  nt <- (ncase + ncont)
  P <- ncase / (ncase + ncont)  # Proportion of cases in the sample
  
  wv <- (1 - P) * K / (P * (1 - K))  # Weighting factor to convert between scales
  wt <- y0 + 1
  wt[wt == 2] <- wv  # Weighting array
  control <- 0
  
  ## Compute weighted R^2 from logistic null model
  phenname <- y
  form0 <- as.formula(paste0(phenname, " ~ ", covars))
  lrmv <- glm(form0, family = binomial(logit), data = df)  # Logistic model
  vr <- runif(nt, 0, 1)  # Uniform random values
  vsel <- lrmv$linear.predictors[y0 == control | vr < wv]  # Select controls and a proportion (wv) of cases
  R2mod_liab_null <- var(vsel) / (var(vsel) + pi^2 / 3)
  
  ## Compute weighted R^2 from logistic full model
  form0 <- as.formula(paste0(phenname, " ~ ", x, " + ", covars))
  lrmv <- glm(form0, family = binomial(logit), data = df)  # Logistic model
  vr <- runif(nt, 0, 1)  # Uniform random values
  vsel <- lrmv$linear.predictors[y0 == control | vr < wv]  # Select controls and a proportion (wv) of cases
  R2mod_liab_full <- var(vsel) / (var(vsel) + pi^2 / 3)
  
  ## Compute liability scale R^2
  R2_liab_delta <- R2mod_liab_full - R2mod_liab_null
  R2_liab_delta_over_residual <- (R2mod_liab_full - R2mod_liab_null) / (1 - R2mod_liab_null)
  return(c(R2mod_liab_null, R2mod_liab_full, R2_liab_delta, R2_liab_delta_over_residual))
}