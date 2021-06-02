# Preparation----------------------------------------------------------------
## Load packages -----------------------------------------------------------
library(gtools)
library(epicoda) # Installed from Github using devtools::install_github("activityMonitoring/epicoda")

install.packages("ggtern")
library(ggtern)

## Load data ---------------------------------------------------------------
df <-  readRDS(
  paste0(
    "epiAnalysis/inputData/",
    name_of_current_run,
    "_ready_to_use.RDS"
  )
)

## Plot data on simplex ------------------------------------------------
df[, "PA"] <- df$LIPA + df$MVPA
df[, "Sleep"] <- df$sleep

p1 <- epicoda:::plot_confidence_region_ternary(
  data = df,
  parts_to_plot = c("Sleep", "SB", "PA"),
  mark_points = comp_mean(data = df, comp_labels = c("Sleep", "SB", "PA")),
  probs = c(0.25, 0.5, 0.75),
  suppress_legend = TRUE
)

svg(
  paste0("epiAnalysis/plots/",
         name_of_current_run,
         "simplex_plot.svg",
         sep = ""),
  width = 15,
  height = 10
)
p1
dev.off()


## Plot data on simplex by overall activity ----------------------------
df$indic <- quantcut(
  df$acc.overall.avg,
  q = c(0, 0.05, 0.95, 1),
  labels = c("Least active 5%", "Neither", "Most active 5%")
)
df_mini <- df[!(is.na(df$indic)) & (df$indic != "Neither"), ]
df_mini$indic <- as.factor(as.character(df_mini$indic))

p2 <- epicoda:::plot_confidence_region_ternary(
  data = df_mini,
  parts_to_plot = c("Sleep", "SB", "PA"),
  groups = c("indic"),
  probs = c(0.25, 0.5, 0.75),
  suppress_legend = TRUE
)
svg(
  paste0(
    "epiAnalysis/plots/",
    name_of_current_run,
    "simplex_plot_split.svg",
    sep = ""
  ),
  width = 15,
  height = 10
)
p2
dev.off()

svg(
  paste0("epiAnalysis/plots/",
         name_of_current_run,
         "simplex_plots.svg",
         sep = ""),
  width = 30,
  height = 10
)
ggtern::grid.arrange(
  grobs = list(p1, p2),
  widths = c(1, 1),
  heights = c(1),
  layout_matrix = rbind(c(1, 2))
)
dev.off()
