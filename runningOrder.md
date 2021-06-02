# 

# Running Order: R Scripts to produce final results

1. Change name_of_current_run in all scripts 
2. Commit and record hash associated with run (automatic- can be found from name_of_current_run)
3. Clear R environment
4. Run ukbDataPrep/preprocessing.R
5. Run epiAnalysis/analysis.R up to part using ggtern
6. Run classifierDevelopment/scripts/reportingPerformance/check_precision_and_recall.R
7. Run ukbAccProcessing/scripts/acc_plots_over_the_day.R
8. Commit again to make sure lockfile correctly recorded.
9. Run final section of epiAnalysis/analysis.R involving ggtern package. 

# Additional Results Generated in Python 

1. On BMRC system, source skylake environment. 
2. Run: 