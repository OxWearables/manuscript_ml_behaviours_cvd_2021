# Preparation----------------------------------------------------------------
## Load packages -----------------------------------------------------------
library(survival)
library(Epi)
library(rlist)
library(gtools)
library(EValue)
library(xts)
library(ggplot2)
library(epicoda) # Installed from Github using devtools::install_github("activityMonitoring/epicoda")

## Source helper functions---------------------------------------------------
source("epiAnalysis/useful_functions/med_and_iqr.R")
source("epiAnalysis/useful_functions/arrange_plots_matrix.R")
source("epiAnalysis/useful_functions/forest_plot_examples_with_evals.R")  # This still needs tidying
source("epiAnalysis/useful_functions/compare_plot2.R")
source("epiAnalysis/useful_functions/compare_plot3.R")
source("epiAnalysis/useful_functions/compare_plot_linear.R")

## Load data ---------------------------------------------------------------
df <-  readRDS(
  paste0(
    "epiAnalysis/inputData/",
    name_of_current_run,
    "_ready_to_use.RDS"
  )
)

df_only_fu <-
 readRDS(
    paste0(
      "epiAnalysis/inputData/",
      name_of_current_run,
      "_only_fu.RDS"
    )
  )
df_sensitivity <-
  readRDS(
    paste0(
      "epiAnalysis/inputData/",
      name_of_current_run,
      "_sensitivity.RDS"
    )
  )


## Set up values used throughout for comp_labels and covariates--------------------------------------------------------------------
# Comp labels
comp_labels <-
  c("sleep", "SB", "LIPA", "MVPA")
tl <-
  transf_labels(comp_labels,
                transformation_type = "ilr")

# List of covariates except sex and bmi
covs <-
  c(
    "ethnicity",
    "smoking",
    "alcohol",
    "fruit_and_veg_cats",
    "red_and_processed_meat_cats",
    "oily_fish",
    "TDI_quartiles",
    "education_cats"
  )

# List of covariates for descriptive tables
covs_cat <- c('age_cats', 'sex', covs, 'BMI_cats')

## Notes --------------------------------------------------------------------
# - Throughout the det limit is automatically calculated as the minimum observed value in the data

# Descriptive analyses ----------------------------------------------------
## Calculate compositional mean ----------------------------------------
cm <- comp_mean(df, comp_labels = comp_labels, units = "hr/day")
cm_from_df <- cm

## Plot compositional mean as pie chart -------------------------------
df$Sleep <- df$sleep
cm <- comp_mean(
  data = df ,
  comp_labels = c("Sleep", "SB", "LIPA", "MVPA"),
  rounded_zeroes = TRUE,
  units = "hr/day"
)

cm_df <- data.frame(matrix(nrow = 0, ncol = 3))
colnames(cm_df) <- c("Behaviour", "value", "constant")
for (activity in c("Sleep", "SB", "LIPA", "MVPA")) {
  cm_df <-
    rbind(cm_df,
          data.frame(
            "Behaviour" = activity,
            "value" = cm[1, activity],
            "constant" = 1
          ))
}
cm_df$Behaviour <-
  factor(cm_df$Behaviour, levels = c("Sleep", "SB", "LIPA", "MVPA"))

svg(
  paste0("epiAnalysis/plots/",
         name_of_current_run,
         "_pie.svg",
         sep = ""),
  width = 10,
  height = 10
)
ggplot2::ggplot(cm_df, ggplot2::aes(x = constant, y = value, fill = Behaviour)) +
  ggplot2::geom_bar(stat = "identity") +
  ggplot2::labs(title = " ",  x = " ", y = " ") +
  ggplot2::coord_polar("y") +
  ggplot2::theme(
    axis.ticks = ggplot2::element_blank(),
    axis.text.y = ggplot2::element_blank(),
    axis.text.x = ggplot2::element_blank()
  ) +
  ggplot2::theme(
    plot.background = ggplot2::element_rect(fill = "white"),
    panel.background = ggplot2::element_rect(fill = "white"),
    text = ggplot2::element_text(
      size = 15,
      face = 2,
      colour = "black"
    ),
    axis.text = ggplot2::element_text(
      size = 18,
      face = 2,
      colour = "black"
    ),
    line = ggplot2::element_line(size = 1, colour = "black")
  )
dev.off()

## Descriptive tables ------------------------------------
for (label in c("Sleep", comp_labels)) {
  df[, paste0(label, "(hr/day)")] <- df[, label] * 24
  df[, paste0(label, "(min/day)")] <- df[, label] * 24 * 60
}

table_of_variables <-
  generate_table_covariates(
    df,
    comp_labels = c(
      "Sleep(hr/day)",
      "SB(hr/day)",
      "LIPA(hr/day)",
      "MVPA(min/day)"
    ),
    covariates = covs_cat
  )

write.csv(
  table_of_variables,
  paste0(
    "epiAnalysis/plots/",
    name_of_current_run ,
    "_demographic_variables.csv",
    sep = ""
  )
)

# Modelling----------------------------------------------------------------
## Main dataset ----------------------------------------------------------
minimally_adjusted_model <-
  comp_model(
    type = "cox",
    covariates = c("strata(sex)"),
    outcome = Surv(
      time = df$age_entry,
      time2 = df$age_exit,
      event = df$CVD_event
    ),
    data = df,
    comp_labels = comp_labels,
    rounded_zeroes = TRUE
  )

main_model <-
  comp_model(
    type = "cox",
    covariates = c("strata(sex)", covs),
    outcome = Surv(
      time = df$age_entry,
      time2 = df$age_exit,
      event = df$CVD_event
    ),
    data = df,
    comp_labels = comp_labels,
    rounded_zeroes = TRUE
  )

add_adj_bmi_model <-   comp_model(
  type = "cox",
  covariates = c("strata(sex)", covs, "BMI") ,
  outcome = Surv(
    time = df$age_entry,
    time2 = df$age_exit,
    event = df$CVD_event

  ),
  data = df,
  comp_labels = comp_labels,
  rounded_zeroes = TRUE
)

## Mortality outcome ------------------------------------------------------
death_model <- comp_model(
  type = "cox",
  covariates = c("strata(sex)", covs),
  outcome = Surv(
    time = df$age_entry,
    time2 = df$age_exit_mortality,
    event = df$any_death_from_cvd

  ),
  data = df,
  comp_labels = comp_labels,
  rounded_zeroes = TRUE
)

## Participants without zero values ---------------------------------------
df_zf <- df
for (label in comp_labels) {
  df_zf <- df_zf[df_zf[, label] != 0, ]
}
zf_model <- comp_model(
  type = "cox",
  covariates = c("strata(sex)", covs),
  outcome = Surv(
    time = df_zf$age_entry,
    time2 = df_zf$age_exit,
    event = df_zf$CVD_event
  ),
  data = df_zf,
  comp_labels = comp_labels,
  rounded_zeroes = FALSE
)

## Sensitivity analyses for reverse causation----------------------------
only_fu_model <-
  comp_model(
    type = "cox",
    covariates = c("strata(sex)", covs),
    outcome = Surv(
      time = df_only_fu$age_entry,
      time2 = df_only_fu$age_exit,
      event = df_only_fu$CVD_event

    ),
    data = df_only_fu,
    comp_labels = comp_labels,
    rounded_zeroes = TRUE
  )

main_sensitivity_model <-
  comp_model(
    type = "cox",
    covariates = c("strata(sex)", covs),
    outcome = Surv(
      time = df_sensitivity$age_entry,
      time2 = df_sensitivity$age_exit,
      event = df_sensitivity$CVD_event

    ),
    data = df_sensitivity,
    comp_labels = comp_labels,
    rounded_zeroes = TRUE
  )

## Women, men---------------------------------------------------------
df_women <- df[df$sex == "Female",]
df_men <- df[df$sex == "Male",]

women_model <-  comp_model(
  type = "cox",
  covariates = c(covs),
  outcome = Surv(
    time = df_women$age_entry,
    time2 = df_women$age_exit,
    event = df_women$CVD_event

  ),
  data = df_women,
  comp_labels = comp_labels,
  rounded_zeroes = TRUE
)

men_model <- comp_model(
  type = "cox",
  covariates = c(covs),
  outcome = Surv(
    time = df_men$age_entry,
    time2 = df_men$age_exit,
    event = df_men$CVD_event
  ),
  data = df_men,
  comp_labels = comp_labels,
  rounded_zeroes = TRUE
)

## Younger, older-------------------------------------------------------
df_under_65 <- df[df$age_entry < 365.25 * 65,]
df_over_65 <- df[df$age_entry > 365.25 * 65,]

under_65_model <- comp_model(
  type = "cox",
  covariates = c("strata(sex)", covs),
  outcome = Surv(
    time = df_under_65$age_entry,
    time2 = df_under_65$age_exit,
    event = df_under_65$CVD_event

  ),
  data = df_under_65,
  comp_labels = comp_labels,
  rounded_zeroes = TRUE
)

over_65_model <- comp_model(
  type = "cox",
  covariates = c("strata(sex)", covs),
  outcome = Surv(
    time = df_over_65$age_entry,
    time2 = df_over_65$age_exit,
    event = df_over_65$CVD_event

  ),
  data = df_over_65,
  comp_labels = comp_labels,
  rounded_zeroes = TRUE
)

## Negative control outcome -----------------------------------------
neg_control_model <-
  comp_model(
    type = "cox",
    covariates = c("strata(sex)", covs) ,
    outcome = Surv(
      time = df$age_entry,
      time2 = df$neg_control_acc_exit,
      event = df$neg_control_event_acc,
    ),
    data = df,
    comp_labels = comp_labels,
    rounded_zeroes = TRUE
  )

## Cox model using linear approach--------------------------------------------------
cov_sum <- vector_to_sum(covs)
cov_sum <- paste0(cov_sum, " + strata(sex) + MVPA + LIPA + SB")
linear_ism <-
  coxph(as.formula(
    paste0("Surv(df$age_entry, df$age_exit, df$CVD_event) ~" , cov_sum)
  ), data = df)
summary(linear_ism)

## Tests of assumptions ------------------------------------------------------------
cox.zph(minimally_adjusted_model)
cox.zph(main_model)
cox.zph(add_adj_bmi_model)
cox.zph(zf_model)
cox.zph(only_fu_model)
cox.zph(main_sensitivity_model)
cox.zph(women_model)
cox.zph(men_model)
cox.zph(under_65_model)
cox.zph(over_65_model)
cox.zph(neg_control_model)
cox.zph(linear_ism)

plot(cox.zph(main_model))
plot(cox.zph(zf_model))
plot(cox.zph(linear_ism))

## Summarise models -----------------------------------------------------------------
summary(main_model)
tab_coef <-
  tab_coefs(
    type = "cox",
    scale_type = "exp" ,
    covariates = c("strata(sex)", covs),
    outcome = Surv(
      time = df$age_entry,
      time2 = df$age_exit,
      event = df$CVD_event
    ),
    data = df,
    comp_labels = comp_labels,
    rounded_zeroes = TRUE
  )

new_tab_coef_col <-
  paste0(
    format(round(tab_coef$fit, digits = 2), nsmall = 2),
    " (",
    format(round(tab_coef$`2.5 %`, digits = 2), nsmall = 2),
    ", ",
    format(round(tab_coef$`97.5 %`, digits = 2), nsmall = 2),
    ")"
  )
tab_coef$Estimate <- new_tab_coef_col
tab_coef$Variable <- rownames(tab_coef)
tab_coef <- tab_coef[, c("Variable", "Estimate")]
write.csv(tab_coef,
          paste0("epiAnalysis/plots/", name_of_current_run, "model_params.csv"))

# Plotting ----------------------------------------------------------------
## Forest plots ------------------------------------------------------------
cm_df <-
  24 * data.frame(
    get_cm_from_model(
      model = main_model,
      comp_labels = comp_labels,
      transf_labels = tl
    )$cm  )
change_list <- list(list("MVPA", 20 / 60),
                    list("LIPA", 1),
                    list("SB", 1),
                    list("sleep", 1))
comp_list <- list()
for (pair in change_list) {
  part <- pair[[1]]
  change_amount <- pair[[2]]
  comp_list <-
    list.append(
      comp_list,
      change_composition(
        cm_df,
        main_part =  part,
        main_change = change_amount,
        comp_labels = comp_labels
      )
    )
}
names(comp_list) <-
  c(
    paste0("20 min/day more MVPA"),
    paste0("1 hr/day more LIPA"),
    paste0("1 hr/day more SB"),
    paste0("1 hr/day more sleep")
  )

svg(
  paste0("epiAnalysis/plots/",
         name_of_current_run,
         "_figure_4.svg",
         sep = ""),
  width = 13,
  height = 10
)
forest_plot_comp(
  comp_list,
  plot_log = TRUE,
  xllimit = 0.90,
  xulimit = 1.05,
  boxsize = 0.1,
  lwd.ci = 3,
  lwd.xaxis = 3,
  lwd.zero = 3,
  text_settings = forestplot::fpTxtGp(
    label = grid::gpar(
      fontfamily = "sans",
      cex = 1.5,
      fontface = 2
    ),
    xlab = grid::gpar(
      fontfamily = "sans",
      cex = 1.5,
      fontface = 2
    ),
    ticks = grid::gpar(cex = 1.25, fontface = 2)
  ),
  model = main_model,
  comp_labels = comp_labels,
  x_label = "Estimated Hazard Ratio",
  rounded_zeroes = TRUE,
  pred_name = "Hazard Ratio \n(95% CI)"
)
dev.off()

svg(
  paste0(
    "epiAnalysis/plots/",
    name_of_current_run,
    "_figure_4_with_evals.svg",
    sep = ""
  ),
  width = 17,
  height = 10
)
forest_plot_comp_with_evals(
  comp_list,
  plot_log = TRUE,
  xllimit = 0.90,
  xulimit = 1.05,
  boxsize = 0.1,
  lwd.ci = 3,
  lwd.xaxis = 3,
  lwd.zero = 3,
  text_settings = forestplot::fpTxtGp(
    label = grid::gpar(
      fontfamily = "sans",
      cex = 1.25,
      fontface = 2
    ),
    xlab = grid::gpar(
      fontfamily = "sans",
      cex = 1.25,
      fontface = 2
    ),
    ticks = grid::gpar(cex = 1, fontface = 2)
  ),
  model = main_model,
  comp_labels = comp_labels,
  dataset = df,
  x_label = "Estimated Hazard Ratio",
  pred_name = "Hazard Ratio \n(95% CI)",
  temp_in_col = names(comp_list)
)
dev.off()
## Matrix plots: single model ---------------------------------------------------------
svg(
  paste0(
    "epiAnalysis/plots/",
    name_of_current_run,
    "_figure3.svg",
    sep = ""
  ),
  width = 16,
  height = 10.5
)
plot_maxi_matrix_transfers(
  comp_model = main_model,
  comp_labels = comp_labels,
  yllimit = 0.8,
  yulimit = 1.3,
  plot_log = TRUE,
  units = "hr/day",
  granularity = 2000,
  theme = NULL,
  point_specification = ggplot2::geom_point(size = 1)
)
dev.off()

## Matrix plots: model comparison-----------------------------------------
### Set up a data frame which will hold key numbers----------------------
numbers_df <- data.frame(matrix(nrow = 0, ncol = 8))
colnames(numbers_df) <- c("Model", "n", "n_event", "CM: Sleep", "CM: SB", "CM: LIPA", "CM: MVPA", "CM: MVPA (min/day)")

### Iterate over model pairs generating the relevant plot and adding detail to numbers_df -------------------
model_pair_list <-
  list(
    list("under_65", "over_65"),
    list("women", "men"),
    list("main", "minimally_adjusted"),
    list("main", "add_adj_bmi"),
    list("main", "death"),
    list("main", "zf"),
    list("main", "neg_control")
  )

for (pair in model_pair_list) {
  # Get models
  model1 <- get(paste0(pair[[1]], "_model"))
  model2 <- get(paste0(pair[[2]], "_model"))
  mlist <- list(model1, model2)

  # Write main components of df
  for (i in c(1, 2)){
    model <- mlist[[i]]
    name <- pair[[i]]

    cm_hrs <- get_cm_from_model(model, comp_labels = comp_labels, transf_labels = tl)$cm*24
    cm_mins <- get_cm_from_model(model, comp_labels = comp_labels, transf_labels = tl)$cm*24*60
    numbers_df <- rbind(numbers_df, data.frame("Model" = name, "n" = model$n, "n_event"= model$nevent, "CM: Sleep" = cm_hrs$sleep, "CM: SB" = cm_hrs$SB, "CM: LIPA" = cm_hrs$LIPA, "CM: MVPA" = cm_hrs$MVPA, "CM: MVPA (min/day)" = cm_mins$MVPA))
  }

  # Save plot
  svg(
    paste0(
      "epiAnalysis/plots/",
      name_of_current_run,
      "_",
      pair[[1]],
      "_" ,
      pair[[2]],
      ".svg",
      sep = ""
    ),
    width = 22,
    height = 12
  )
  compare_all_transfers_side_by_side(
    comp_model = model1,
    comp_model2 = model2,
    comp_labels = comp_labels,
    yllimit = 0.8,
    yulimit = 1.3,
    plot_log =  TRUE,
    units = "hr/day",
    granularity = 1000,
    point_specification = ggplot2::geom_point(size = 2)
  )

  dev.off()

}
### Do three way plot for sensitivity analyses and record numbers --------------------------
svg(
  paste0(
    "epiAnalysis/plots/",
    name_of_current_run,
    "_supplementary_sensitivity_reverse_causation.svg",
    sep = ""
  ),
  width = 30,
  height = 12
)
compare_all_transfers_side_by_side_three(
  comp_model = main_model,
  comp_model2 = only_fu_model,
  comp_model3 = main_sensitivity_model,
  comp_labels = comp_labels,
  yllimit = 0.8,
  yulimit = 1.3,
  plot_log =  TRUE,
  units = "hr/day",
  granularity = 1000,
  point_specification = ggplot2::geom_point(size = 2)
)
dev.off()

### Write these models into df of numbers
mlist <- list(only_fu_model, main_sensitivity_model)
pair <- list("only_fu", "main_sensitivity")
for (i in c(1, 2)){
  model <- mlist[[i]]
  name <- pair[[i]]

  cm_hrs <- get_cm_from_model(model, comp_labels = comp_labels, transf_labels = tl)$cm*24
  cm_mins <- get_cm_from_model(model, comp_labels = comp_labels, transf_labels = tl)$cm*24*60
  numbers_df <- rbind(numbers_df, data.frame("Model" = name, "n" = model$n, "n_event"= model$nevent, "CM: Sleep" = cm_hrs$sleep, "CM: SB" = cm_hrs$SB, "CM: LIPA" = cm_hrs$LIPA, "CM: MVPA" = cm_hrs$MVPA, "CM: MVPA (min/day)" = cm_mins$MVPA))
}

### Do plot with linear model--------------------------------------------------------------------------------------------
svg(
  paste0(
    "epiAnalysis/plots/",
    name_of_current_run,
    "_main_linear_ism.svg",
    sep = ""
  ),
  width = 22,
  height = 12
)
compare_all_transfers_ism_side_by_side(
  comp_model = main_model,
  ism_model = linear_ism,
  comp_labels = comp_labels,
  yllimit = 0.8,
  yulimit = 1.3,
  plot_log =  TRUE,
  lower_quantile = 0.05,
  upper_quantile = 0.95,
  units = "hr/day",
  granularity = 1000,
  point_specification = ggplot2::geom_point(size = 2)
)
dev.off()

### Write numbers_df --------------------------------------------------
write.csv(numbers_df, paste0("epiAnalysis/plots/", name_of_current_run, "details_for_plots.csv"))

# Other numbers for paper-------------------------------------------------------------
## Specific_predictions ---------------------------------------------------------------
cm <- get_cm_from_model(model = main_model, comp_labels = comp_labels, transf_labels = tl)$cm
new <-
  rbind(
    cm,
    change_composition(cm, main_part = "SB", at_expense_of = "LIPA", main_change = 1/24, comp_labels = comp_labels),
    change_composition(cm, main_part = "LIPA", at_expense_of = "SB", main_change = 1/24, comp_labels = comp_labels),
    change_composition(cm, main_part = "SB", at_expense_of = "MVPA", main_change = 0.25/24, comp_labels = comp_labels),
    change_composition(cm, main_part = "MVPA", at_expense_of = "SB", main_change = 0.25/24, comp_labels = comp_labels)
  )
preds <-  predict_fit_and_ci(
  model =  main_model,
  new_data = new,
  comp_labels = comp_labels,
  units = "hr/day"
)
preds <- preds[, c("fit", "lower_CI", "upper_CI")]
rownames(preds) <- c("Compositional mean", "1 hr/day SB from LIPA", "1 hr/day LIPA from SB", "15 min/day SB from MVPA", "15 min/day MVPA from SB")
p <- format(round(preds, digits = 2), nsmall = 2)
write.csv(p, paste0("epiAnalysis/plots/", name_of_current_run, "number_for_substitutions.csv"))

## Proportion explained ----------------------------------------------------------------------
mm <- predict_fit_and_ci(main_model,
                         comp_list[["20 min/day more MVPA"]],
                         comp_labels = comp_labels,
                         terms = TRUE)
bmi_adj <- predict_fit_and_ci(add_adj_bmi_model,
                              comp_list[["20 min/day more MVPA"]],
                              comp_labels = comp_labels,
                              terms = TRUE)

d <- rbind(mm[, c("fit", "lower_CI", "upper_CI")], bmi_adj[, c("fit", "lower_CI", "upper_CI")])
rownames(d) <- c("Main model", "Additionally adjusted for BMI")
write.csv(d, paste0("epiAnalysis/plots/", name_of_current_run, "_model_preds.csv"))
bmi_adj <- bmi_adj['fit']
mm <- mm['fit']
(log(mm) - log(bmi_adj)) / log(mm)

# Miscellaneous checks ----------------------------------------------------
## No duplicate participants
if (nrow(df)!= length(unique(df$eid))){
  stop("There is not one row per participant")
}

## Check data format as expected
s_comp <- as.vector(apply(df[, comp_labels], 1, sum))
if (!isTRUE(all.equal(s_comp, rep(1, length.out = length(s_comp)), tolerance = 1e-5))){
  stop("Check input data: compositions not specified in proportion-of-one-day format.")
}

s_comp_new <- as.vector(apply(new[, comp_labels], 1, sum))
if (!isTRUE(all.equal(s_comp_new, rep(1, length.out = length(s_comp_new))))){
  stop("Check newly generated data for predictions: compositions not specified in proportion-of-one-day format.")
}

## Check all compositions in list have sum to 24
for (i in comp_list) {
  if (!(isTRUE(all.equal(sum(i),24)))){
    stop("There was an error in the production of comp_list for the forest plot")
  }
}

## Check different methods of calculating same mean concur
if (!isTRUE(all.equal(cm_from_df/24, cm))){
  stop("Different methods of calculating compositional mean do not agree")
}
## Check results would be similar: using simple adjustment for age, using simple adjustment for sex
simple_sex <-
  comp_model(
    type = "cox",
    covariates = c("sex", covs),
    outcome = Surv(
      time = df$age_entry,
      time2 = df$age_exit,
      event = df$CVD_event
    ),
    data = df,
    comp_labels = comp_labels,
    rounded_zeroes = TRUE
  )

simple_age <-
  comp_model(
    type = "cox",
    covariates = c("strata(sex)", "age_entry", covs),
    outcome = Surv(
      time =  -df$age_entry + df$age_exit,
      event = df$CVD_event
    ),
    data = df,
    comp_labels = comp_labels,
    rounded_zeroes = TRUE
  )

# Understanding the scale of the data
for (behaviour in comp_labels) {
  print(behaviour)
  print(24 * (median(df[, behaviour]) - quantile(df[, behaviour], probs = 0.25)))
  print(24 * 60 * (median(df[, behaviour]) - quantile(df[, behaviour], probs = 0.25)))

  print(-24 * (median(df[, behaviour]) - quantile(df[, behaviour], probs = 0.75)))
  print(-24 * 60 * (median(df[, behaviour]) - quantile(df[, behaviour], probs = 0.75)))

  print(12 * (quantile(df[, behaviour], probs = 0.75) - quantile(df[, behaviour], probs = 0.25)))
  print(12 * 60 * (quantile(df[, behaviour], probs = 0.75) - quantile(df[, behaviour], probs = 0.25)))
}


