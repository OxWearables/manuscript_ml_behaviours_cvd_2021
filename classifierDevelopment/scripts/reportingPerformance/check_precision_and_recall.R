# ==============================================================================================
# LOAD PACKAGES AND DATA; SET UP NAME OF CURRENT RUN
library(data.table)
library(ggplot2)
df_all <-
  data.frame(fread(
    "classifierDevelopment/inputData/sep20_LOO_classification.csv"
  )) # change the data here
name_of_current_run <- paste0(Sys.Date(), "_analysis_new_dates_")

#==============================================================================================
# SET UP DATA FRAME FOR RECORDING RESULTS
pr <- data.frame(matrix(ncol = 8, nrow = 0))
colnames(pr) <-
  c(
    "Minimum_time_in_behaviour",
    "Behaviour",
    "Mean_precision",
    "Lower_limit_precision",
    "Upper_limit_precision",
    "Mean_recall",
    "Lower_limit_recall",
    "Upper_limit_recall"
  )

#==================================================================================================
# CALCULATE PRECISION AND RECALL AFTER EXCLUDING SOME PARTICIPANTS
for (i in seq(2, 40, by = 2)) {
  # Calculate results excluding those with 1 - 20 minutes in behaviour
  for (behaviour in c("MVPA", "light", "sedentary", "sleep")) {
    precisions <- c() # Set up empty vector of precisions
    recalls <- c() # Set up empty vector of recalls
    for (pid in unique(df_all$participant)) {
      df <-
        df_all[df_all$participant == pid,] # Restrict to single participant

      if (nrow(df[df$label == behaviour,]) <= i) {
        print("Few examples")
      }
      else {
        recalls <-
          c(recalls, nrow(df[df$label == behaviour &
                               df$predicted == behaviour,]) / nrow(df[df$label == behaviour,]))
        if (!(behaviour %in% df$predicted)) {
          print(paste(
            behaviour,
            "unsupported for" ,
            pid,
            ": Precision not calculated"
          ))
        }
        else {
          precisions <-
            c(precisions, nrow(df[df$label == behaviour &
                                    df$predicted == behaviour,]) / nrow(df[df$predicted == behaviour,]))
        }
      }
    }

    print(behaviour)

    print("Precision:")
    p_mean <- mean(precisions)
    error <-
      qt(0.975, df = length(precisions) - 1) * sd(precisions) / sqrt(length(precisions))
    p_lower <- p_mean - error
    p_higher <- p_mean + error

    print("Recall:")
    r_mean <- (mean(recalls))
    error <-
      qt(0.975, df = length(recalls) - 1) * sd(recalls) / sqrt(length(recalls))
    r_lower <- (r_mean - error)
    r_higher <- (r_mean + error)

    last_row <-
      data.frame(i / 2,
                 behaviour,
                 p_mean,
                 p_lower,
                 p_higher,
                 r_mean,
                 r_lower,
                 r_higher)

    colnames(last_row) <-
      c(
        "Minimum_time_in_behaviour",
        "Behaviour",
        "Mean_precision",
        "Lower_limit_precision",
        "Upper_limit_precision",
        "Mean_recall",
        "Lower_limit_recall",
        "Upper_limit_recall"
      )
    pr <- rbind(pr, last_row)

  }
}

#============================================================================
# TEST FOR CORRECT BEHAVIOUR OF CODE
t.test(precisions)$conf.int
pr[nrow(pr), c("Lower_limit_precision", "Upper_limit_precision")]

#============================================================================
# REORGANISE DATA FRAME FOR PLOTTING
pr$Behaviour <- as.character(pr$Behaviour)
pr$Behaviour[pr$Behaviour == "light"] <- "Light activity"
pr$Behaviour[pr$Behaviour == "MVPA"] <-
  "Moderate-to-vigorous activity"
pr$Behaviour[pr$Behaviour == "sleep"] <- "Sleep"
pr$Behaviour[pr$Behaviour == "sedentary"] <- "Sedentary behaviour"
pr$Behaviour <- as.factor(pr$Behaviour)
pr$Behaviour <-
  relevel(pr$Behaviour, ref = "Moderate-to-vigorous activity")

#=============================================================================
# PLOT
svg(
  paste0(
    "classifierDevelopment/plots/",
    name_of_current_run,
    "_precision.svg",
    sep = ""
  ),
  width = 10,
  height = 7
)
ggplot(data = pr, aes(x = Minimum_time_in_behaviour, y = Mean_precision)) +
  geom_point(data = pr,
             aes(x = Minimum_time_in_behaviour, y = Mean_precision, color = Behaviour)) +
  geom_errorbar(
    data = pr,
    aes(
      x = Minimum_time_in_behaviour,
      ymin = Lower_limit_precision,
      ymax = Upper_limit_precision,
      color = Behaviour
    )
  ) +
  xlab("Minimum required minutes in behaviour") +
  ylab("Participant-wise mean precision") +
  theme(
    text = element_text(size = 16, face = 2),
    axis.text.x = element_text(colour = "black"),
    axis.text.y = element_text(colour = "black"),
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 12)
  ) + ylim(0, 1)
dev.off()

svg(
  paste0(
    "classifierDevelopment/plots/",
    name_of_current_run,
    "_recall.svg",
    sep = ""
  ),
  width = 10,
  height = 7
)
ggplot(data = pr, aes(x = Minimum_time_in_behaviour, y = Mean_recall)) +
  geom_point(data = pr,
             aes(x = Minimum_time_in_behaviour, y = Mean_recall, color = Behaviour)) +
  geom_errorbar(
    data = pr,
    aes(
      x = Minimum_time_in_behaviour,
      ymin = Lower_limit_recall,
      ymax = Upper_limit_recall,
      color = Behaviour
    )
  ) +
  xlab("Minimum required minutes in behaviour") +
  ylab("Participant-wise mean recall") +
  theme(
    text = element_text(size = 16, face = 2),
    axis.text.x = element_text(colour = "black"),
    axis.text.y = element_text(colour = "black"),
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 12)
  ) + ylim(0, 1)
dev.off()
