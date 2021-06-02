# LOAD PACKAGES AND HELPER FUNCTIONS; NAME RUN
library(ggplot2)
library(data.table)
source("ukbAccProcessing/useful_functions/average_day_plot.R")

# LOAD DATA
a <-
  data.frame(
    fread(
     "ukbAccProcessing/inputData/sep20-summary-all.csv"
    )
  ) # all acc data
df <- readRDS(# analytic dataset
  paste0(
    "epiAnalysis/inputData/",
    name_of_current_run,
    "_ready_to_use.RDS"
  ))

# RESTRICT TO PATTICIPANTS IN THE FINAL ANALYTIC SAMPLE
a$eid <- gsub("_90001_0_0.gz", "", a$eid)
a <- a[a$eid %in% df$eid,]

# PLOT AVERAGE DAY FOR EACH BEHAVIOUR
for (label in list(
  c("MVPA", "Probability in MVPA"),
  c("light", "Probability in LIPA"),
  c("sedentary", "Probability in SB"),
  c("sleep", "Probability in sleep")
)) {
  lab <- paste0("p_", label[1])
  assign(lab, plotAverageDay(a, paste0(label[1], ".hourOfDay."), ".avg", yAxisLabel = label[2]))
}

# WRITE OUT FIGURE
svg(
  paste0(
    "ukbAccProcessing/plots/",
    name_of_current_run,
    "_face_validity.svg",
    sep = ""
  ),
  width = 10,
  height = 4
)

gridExtra::grid.arrange(
  grobs = list(p_MVPA, p_light, p_sedentary, p_sleep),
  layout_matrix = cbind(c(4, 3), c(2, 1))
)
dev.off()
