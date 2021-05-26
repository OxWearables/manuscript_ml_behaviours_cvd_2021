med_and_iqr <- function(data, dp) {
  return(paste(
    format(round(median(data, na.rm = TRUE), dp), nsmall = dp),
    "(",
    format(round(quantile(data, 0.25, na.rm = TRUE), dp), nsmall = dp),
    ",",
    format(round(quantile(data, 0.75, na.rm = TRUE), dp), nsmall = dp),
    ")",
    sep = ""
  ))
}

med_and_iqr_all_behav <- function(data, comp_labels = NULL) {
  output <- data.frame(matrix(nrow = 1, ncol = 0))
  if (is.null(comp_labels)) {
    stop("Missing argument for comp_labels.")
  }
  for (activity in comp_labels) {
    output[, activity] <- med_and_iqr(data[, activity], dp = 1)
  }
  if (activity == "MVPA(hr/day)"){
    output[, activity] <- med_and_iqr(data[, activity], dp = 2)
  }
  if (activity == "MVPA(min/day)"){
    output[, activity] <- med_and_iqr(data[, activity], dp = 0)
  }
  return(output)
}


generate_table_covariates <- function(data, comp_labels, covariates){
  act_var_by_factors <-
    data.frame(matrix(nrow = 0, ncol = (length(comp_labels) + 3)))
  colnames(act_var_by_factors) <- c("Variable", "Level", "n_and_percent", comp_labels)
  overall_n <- nrow(data)
  act_var_by_factors <-
    rbind(
      act_var_by_factors,
      data.frame(
        "Variable" = "Overall",
        "Level" = "",
        "n_and_percent" = paste(nrow(data), "(100)"),
        med_and_iqr_all_behav(data, comp_labels)
      )
    )

  for (variable in covariates){
    for (level in levels(data[, variable])){
      n <- nrow(data[data[, variable] == level, ])
      act_var_by_factors <- rbind(
        act_var_by_factors,
        data.frame(
          "Variable" = variable,
          "Level" = level,
          "n_and_percent" = paste(n, "\ (", format(round(100*n/overall_n, 0), nsmall = 0), ")", sep = ""),
          med_and_iqr_all_behav(data[data[, variable] == level, ], comp_labels)
        )
      )
    }
  }
  return(act_var_by_factors)
}
