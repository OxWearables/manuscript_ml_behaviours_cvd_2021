# USE RUNNAME TO BE ABLE TO PULL OLD FILES =========================================================
name_of_current_run <- "2022-01-20update_negative_control"

# LOAD PACKAGES AND HELPER FUNCTIONS; NAME RUN======================================================
library(ggplot2)
library(data.table)
source("ukbAccProcessing/useful_functions/average_day_plot_by_group.R")

# LOAD DATA=========================================================================================
a <-
  data.frame(fread("ukbAccProcessing/inputData/sep20-summary-all.csv")) # all acc data
participant <- fread(
  "ukbDataPrep/inputData/participant_new_nc_20220114.csv",
  stringsAsFactors = FALSE,
  data.table = FALSE,
  check.names = TRUE,
  tz = ""
)

extra_cols <- fread(# TO EXTRACT EXTRA COLUMNS NOT RECORDED IN MAIN DATA
  "../Analyses/thesis_only_analyses/data/thesis-phenoData-20220124.csv",
  stringsAsFactors = FALSE,
  data.table = FALSE,
  check.names = TRUE,
  tz = ""
)

df <- readRDS(# analytic dataset
  paste0(
    "epiAnalysis/inputData/",
    name_of_current_run,
    "_ready_to_use.RDS"
  ))


# NAME OF CURRENT RUN UPDATE FOR THESIS==============================================================
name_of_current_run <- "2022-06-22"

# RESTRICT TO PATTICIPANTS IN THE FINAL ANALYTIC SAMPLE==============================================
a$eid <- gsub("_90001_0_0.gz", "", a$eid)
a <- a[a$eid %in% df$eid, ]

a <- merge(a, participant, by = "eid")
a <- merge(a, df[, c("age_entry", "eid")], by = "eid")

a <- merge(a, extra_cols, by = "eid")

# TIME OF YEAR PLOT===================================================================================
a$month <- lubridate::month(a$file.startTime)
a$dst <- "UNCLEAR"
a$dst[a$month %in% c(4, 5, 6, 7, 8, 9)] <- "summer"
a$dst[a$month %in% c(11, 12, 1, 2)] <- "winter"
a$dst <- as.factor(a$dst)
plotAverageDayGroupWise(
  a,
  "dst",
  "sleep.hourOfDay.",
  ".avg",
  yAxisLabel = "sleep",
  title ="Checking DST variable correctly incorporated"
)


# PREPROCESSING OF BEHAVIOURAL VARIABLES =============================================================
a[, "GetMorn"] <-
  factor(
    a[, "GetMorn"],
    ordered = TRUE,
    levels = c("Very easy", "Fairly easy", "Not very easy", "Not at all easy")
  )
a[, "JobInvolvNightShiftWork"] <-
  plyr::revalue(
    a[, "JobInvolvNightShiftWork"],
    c(
      "Prefer not to answer" = NA,
      "Do not know" = NA,
      "Always" = "Shift work - always nights",
      "Usually" = "Shift work - usually  nights",
      "Sometimes" = "Shift work - sometimes nights",
      "Never/rarely" = "Shift work - never/rarely nights"
    )
  )
a[, "JobInvolvNightShiftWork"] <-
  plyr::mapvalues(a[, "JobInvolvNightShiftWork"], "", "No shift work")
a[, "JobInvolvNightShiftWork"] <-
  factor(
    a[, "JobInvolvNightShiftWork"],
    ordered = TRUE,
    levels = c(
      "Shift work - always nights",
      "Shift work - usually  nights",
      "Shift work - sometimes nights",
      "Shift work - never/rarely nights",
      "No shift work"
    )
  )

a$JobInvolveHeavyManualPhysicalWork <- a$p816_i0 # NOTE PARTICIPANTS WITHOUT A JOB WILL BE NA FOR THESE VARIABLES
a$JobInvolveWalkingStanding <- a$p806_i0

# MAKE PLOTS =========================================================================================================
# GROUPINGS FOR WHICH USE ALL DAYS =================================================================
for (group in c(
  "JobInvolvNightShiftWork",
  "JobInvolvShiftWork",
  "GetMorn",
  "Morning.evenPerson.Chronotype.",
  "NapDureDay"
)) {

  # FINAL ADMIN ====================================================================================
  a[, group] <- as.factor(a[, group]) # FACTOR COERCION
  a[, group] <-
    plyr::revalue(a[, group], c("Prefer not to answer" = NA, "Do not know" = NA)) # ON THE FLY NA PROCESSING


  # TITLE ASSIGNMENT===============================================================================
  tit <- NULL # BEGIN WITH NULL TITLE

  if (group == "JobInvolvNightShiftWork") {
    dat <- a[a$age_entry < 365.25 * 60,]
    tit <- "Working night shifts (under 60s only)"
  }
  else {
    dat <- a
  }

  if (group == "GetMorn") {
    tit <- "Ease of getting up in the morning"
  }

  if (group == "NapDureDay") {
    tit <- "Napping during the day"
  }

  # PRINTING ======================================================================================
  print(group)
  print(levels(dat[, group]))
  print(nrow(dat))

  # DO AVERAGE-DAY-BY-GROUP PLOTS==================================================================
  for (label in list(
    c("MVPA", "Probability in MVPA"),
    c("light", "Probability in LIPA"),
    c("sedentary", "Probability in SB"),
    c("sleep", "Probability in sleep")
  )) {
    lab <- paste0("p_", label[1])
    assign(
      lab,
      plotAverageDayGroupWise(
        dat,
        group,
        paste0(label[1], ".hourOfDay."),
        ".avg",
        yAxisLabel = label[2],
        title = tit
      )
    )
  }

  # WRITE OUT COMBINED FIGURE ======================================================================
  # svg(
  #   paste0(
  #     "ukbAccProcessing/plots/",
  #     name_of_current_run,
  #     "_face_validity_",
  #     group,
  #     ".svg",
  #     sep = ""
  #   ),
  #   width = 10,
  #   height = 4
  # )
  #
  # gridExtra::grid.arrange(
  #   grobs = list(p_MVPA, p_light, p_sedentary, p_sleep),
  #   layout_matrix = cbind(c(4, 3), c(2, 1))
  # )
  # dev.off()

  # WRITE OUT SLEEP PLOT===========================================================================
  svg(
    paste0(
      "ukbAccProcessing/plots/",
      name_of_current_run,
      "_face_validity_sleep_",
      group,
      ".svg",
      sep = ""
    ),
    width = 10,
    height = 4
  )
  print(p_sleep)
  dev.off()
}

# GROUPINGS FOR WHICH USE UNDER 60s and WEEKDAYS ONLY==============================================================================
dat <- a[a$age_entry < 365.25 * 60,] # Restrict to under 60s
for (group in c("JobInvolveHeavyManualPhysicalWork",
                  "JobInvolveWalkingStanding")) {
    dat[, group] <- plyr::revalue(dat[, group], c("Prefer not to answer" = NA, "Do not know" = NA))
    dat[, group] <- plyr::mapvalues(dat[, group], "", NA)
    dat[, group] <- factor(dat[, group], ordered = TRUE, levels = c("Never/rarely", "Sometimes", "Usually", "Always"))

    tit <- NULL
    if (group == "JobInvolveHeavyManualPhysicalWork"){
      tit <- "Job involves heavy manual or physical work (under 60s only, weekdays)"
    }

    if (group == "JobInvolveWalkingStanding"){
      tit <- "Job involves walking or standing (under 60s only, weekdays)"
    }

    # PRINTING
    print(group)
    print(levels(dat[, group]))
    print(nrow(dat))

    # PLOT GROUPS
    for (label in list(
      c("MVPA", "Probability in MVPA"),
      c("light", "Probability in LIPA"),
      c("sedentary", "Probability in SB"),
      c("sleep", "Probability in sleep")
    )) {
      lab <- paste0("p_", label[1])
      assign(
        lab,
        plotAverageDayGroupWise(
          dat,
          group,
          paste0(label[1], ".hourOfWeekday."),
          ".avg",
          yAxisLabel = label[2],
          title = tit
        )
      )
    }

    for (label in list(
      c("MVPA", "Probability in MVPA")
    )) {
      lab <- paste0("p_", label[1], "_zoomed")
      assign(
        lab,
        plotAverageDayGroupWise(
          dat,
          group,
          paste0(label[1], ".hourOfWeekday."),
          ".avg",
          yAxisLabel = label[2],
          title = tit,
          ylim = 0.075
        )
      )
    }

    # # WRITE OUT COMBINED FIGURE==============================
    # svg(
    #   paste0(
    #     "ukbAccProcessing/plots/",
    #     name_of_current_run,
    #     "_face_validity_weekday",
    #     group,
    #     ".svg",
    #     sep = ""
    #   ),
    #   width = 10,
    #   height = 4
    # )
    #
    # gridExtra::grid.arrange(
    #   grobs = list(p_MVPA, p_light, p_sedentary, p_sleep),
    #   layout_matrix = cbind(c(4, 3), c(2, 1))
    # )
    # dev.off()

    # WRITE OUT FIGURES FOR EACH BEHAVIOURS==================
    svg(
      paste0(
        "ukbAccProcessing/plots/",
        name_of_current_run,
        "_face_validity_weekday_light_",
        group,
        ".svg",
        sep = ""
      ),
      width = 10,
      height = 4
    )
    print(p_light)
    dev.off()
    svg(
      paste0(
        "ukbAccProcessing/plots/",
        name_of_current_run,
        "_face_validity_weekday_MVPA_",
        group,
        ".svg",
        sep = ""
      ),
      width = 10,
      height = 4
    )
    print(p_MVPA_zoomed)
    dev.off()
}

