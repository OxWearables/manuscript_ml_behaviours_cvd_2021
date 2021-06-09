# SET NAME OF CURRENT RUN==============================================
name_of_current_run <- paste0(Sys.Date(), "_update_BMI_run_")

# SET UP FUNCTIONS FOR SINKING CONSOLE OUTPUT AND CLEARING AFTER EACH================================
open_sinks <- function(filestart){
  output_file <- file(paste0(filestart, name_of_current_run, "console_output.txt"), open = "a")
  msg_file <- file(paste0(filestart, name_of_current_run, "message_output.txt"), open = "a")
  sink(output_file, append = TRUE, type = "output") # Writing console output to log file
  sink(msg_file, append = TRUE, type = "message") # Writing console output to log file
}

reset_for_next <- function(){
  sink()
  sink(type = "message")
}

rm(list = ls()[!(ls() %in% c("name_of_current_run", "reset_for_next", "open_sinks"))])

# PREPROCESSING========================================================
open_sinks("ukbDataPrep/plots/")
source("ukbDataPrep/scripts/preprocessing.R")
reset_for_next()
rm(list = ls()[!(ls() %in% c("name_of_current_run", "reset_for_next", "open_sinks"))])

# MAIN ANALYSIS========================================================
open_sinks("epiAnalysis/plots/")
source("epiAnalysis/scripts/analysis.R")
reset_for_next()
rm(list = ls()[!(ls() %in% c("name_of_current_run", "reset_for_next", "open_sinks"))])

# OTHER MISCELLANEOUS PARTS TO ANALYSIS================================
open_sinks("classifierDevelopment/plots/")
source("classifierDevelopment/scripts/reportingPerformance/check_precision_and_recall.R")
reset_for_next()
rm(list = ls()[!(ls() %in% c("name_of_current_run", "reset_for_next", "open_sinks"))])

open_sinks("ukbAccProcessing/plots/")
source("ukbAccProcessing/scripts/acc_plots_over_the_day.R")
reset_for_next()
rm(list = ls()[!(ls() %in% c("name_of_current_run", "reset_for_next", "open_sinks"))])

open_sinks("epiAnalysis/plots/ggtern_")
source("epiAnalysis/scripts/ggtern_plots.R")
reset_for_next()
rm(list = ls()[!(ls() %in% c("name_of_current_run", "reset_for_next", "open_sinks"))])

# OUTPUT DETAILS OF ENVIRONMENT===================================================================
renv::snapshot(
  lockfile = paste0(
    name_of_current_run,
    "_R_environment.lock"
  )
)
