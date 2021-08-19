# ukbAccProcessing 

This subfolder contains files related to processing accelerometer data in UK Biobank.

## Processing 
We applied the [biobankAccelerometerAnalysis tool](https://github.com/activityMonitoring/biobankAccelerometerAnalysis) with the model trained in the `classifierDevelopment` section. Relevant scripts are contained in `scripts/clusterProcessingCmds`.  

## Face validity
We assessed the face validity of the classifier when applied to UK Biobank data by examining the descriptive statistics of the distribution of different behaviours, and by plotting behaviour by time-of-day plots (`scripts/acc_plots_over_the_day.R`).

## Processing on a cluster system
We processed data on the [Oxford BMRC system](https://www.medsci.ox.ac.uk/divisional-services/support-services-1/bmrc), to enable > 100,000 files to be processed efficiently. The [clusterProcessing tool](https://github.com/activityMonitoring/clusterProcessing) contains scripts to enable this. If using the Oxford BMRC system, please note that the scripts used for the current project are no longer recommended: scripts in the `clusterProcessing` folder are preferred.

