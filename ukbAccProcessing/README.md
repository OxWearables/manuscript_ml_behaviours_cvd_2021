# ukbAccProcessing 

This subfolder contains files related to processing accelerometer data in UK Biobank.

## Processing 
Here, we applied the [biobankAccelerometerAnalysis tool](https://github.com/activityMonitoring/biobankAccelerometerAnalysis) with the model trained in the `classifierDevelopment` section. 

### Processing on a cluster system
We processed data on the [Oxford BMRC system](https://www.medsci.ox.ac.uk/divisional-services/support-services-1/bmrc). This enabled 100,000 files to be processed efficiently. The [clusterProcessing tool](https://github.com/activityMonitoring/clusterProcessing) contains scripts to enable this. If using the Oxford BMRC system, please note that the actual scripts included here use settings for cluster submission which are no longer recommended: the `clusterProcessing` folder should be followed of preference.  

## Face validity
We assessed the face validity of the classifier when applied to UK Biobank data by examining the descriptive statistics of the distribution of different behaviours, and by plotting behaviour by time-of-day plots. 
