# Overall Running Order 

This file describes the running order to produce a final set of tables/plots.

Note that there are many earlier steps to processing: processing CAPTURE-24 data; training the relevant machine learning models, including in Leave-One-Participant-Out Analysis; processing UK Biobank accelerometer data; and extracting UK Biobank participant and demographic data. Code/commands for these steps can be found under `classifierDevelopment`, `ukbAccProcessing`, and  `ukbDataPrep`.

## Running Order: R Scripts to produce final results

1. Set name_of_current_run in allRProcessing.R
2. Clear environment
3. Source allRProcessing.R
4. Commit again to make sure lockfile correctly recorded.

## Additional Results Generated in Python 

1. On BMRC system, source skylake environment. 
2. Run: classifierDevelopment/scripts/reportingPerformance/produce_performance_summaries.py
