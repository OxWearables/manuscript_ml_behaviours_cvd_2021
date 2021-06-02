# SET NAME OF CURRENT RUN==============================================
name_of_current_run <- paste0(Sys.Date(), "_paper_ready_run_")

# SET UP FUNCTION FOR CLEARING AFTER EACH================================
reset_for_next <- function(){
  sink()
  sink(type = "message")
  rm(list = setdiff(ls(), "name_of_current_run"))
}
reset_for_next()

# PREPROCESSING========================================================
sink(paste0("ukbDataPrep/plots/", name_of_current_run, "_console_ouput.txt"), append = TRUE, type = "output") # Writing console output to log file
sink(paste0("ukbDataPrep/plots/", name_of_current_run, "_console_message_ouput.txt"), append = TRUE, type = "message") # Writing console output to log file
source("ukbDataPrep/scripts/preprocessing.R")
reset_for_next()

# MAIN ANALYSIS========================================================
sink(paste0("epiAnalysis/plots/", name_of_current_run, "_console_ouput.txt"), append = TRUE, type = "output") # Writing console output to log file
sink(paste0("epiAnalysis/plots/", name_of_current_run, "_console_message_ouput.txt"), append = TRUE, type = "message") # Writing console output to log file
source("epiAnalysis/scripts/analysis.R")
reset_for_next()

# OTHER MISCELLANEOUS PARTS TO ANALYSIS================================
sink(paste0("classifierDevelopment/plots/", name_of_current_run, "_console_ouput.txt"), append = TRUE, type = "output") # Writing console output to log file
sink(paste0("classifierDevelopment/plots/", name_of_current_run, "_console_message_ouput.txt"), append = TRUE, type = "message") # Writing console output to log file
source("classifierDevelopment/scripts/reportingPerformance/check_precision_and_recall.R")
reset_for_next()

sink(paste0("ukbAccProcessing/plots/", name_of_current_run, "_console_ouput.txt"), append = TRUE, type = "output") # Writing console output to log file
sink(paste0("ukbAccProcessing/plots/", name_of_current_run, "_console_message_ouput.txt"), append = TRUE, type = "message") # Writing console output to log file
source("ukbAccProcessing/scripts/acc_plots_over_the_day.R")
reset_for_next()

sink(paste0("epiAnalysis/plots/", name_of_current_run, "_ggtern_console_ouput.txt"), append = TRUE, type = "output") # Writing console output to log file
sink(paste0("epiAnalysis/plots/", name_of_current_run, "_ggtern_console_message_ouput.txt"), append = TRUE, type = "message") # Writing console output to log file
source("epiAnalysis/scripts/ggtern_plots.R")
reset_for_next()

# OUTPUT DETAILS OF ENVIRONMENT===================================================================
renv::snapshot(
  lockfile = paste0(
    name_of_current_run,
    "_R_environment.lock"
  )
)
