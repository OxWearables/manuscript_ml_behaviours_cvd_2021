# classifierDevelopment 

This subfolder contains materials for developing the classifier using the CAPTURE-24 dataset.

## Data
The CAPTURE-24 dataset is a labelled wrist-worn accelerometer dataset. Participants wore a wrist-worn Axivity AX3 alongside a wearable camera, and camera images were labelled by trained annotators with labels from the Compendium of Physical Activities. The CAPTURE-24 dataset is soon to be released and will be described in detail there [LINK TO BE ADDED]. 

## Classifier development
For the classifier development in this manuscript, we followed the steps in the tutorial [here](https://biobankaccanalysis.readthedocs.io/en/latest/usage.html#classifying-different-activity-types). We amended the feature set used, to a restricted set of features not dependent on device orientation, and developed a new set of behavioural labels (sleep, sedentary behaviour, light physical activity behaviours, moderate-to-vigorous physical activity behaviours). 

The classifier developed is available as part of the [biobankAccelerometerAnalysis repository](https://github.com/activityMonitoring/biobankAccelerometerAnalysis) (downloaded under `activityModels/walmsley-jan21.tar`).

## Assessing performance
We assessed performance using the Leave-One-Participant-Out approach, also described in the above tutorial. Metrics are described in detail in the manuscript. The `scripts/reportingPerformance` folder provides relevant scripts. 

Notable aspects of performance assessment included:
- reporting performance of a model trained in all participants only in participants aged > 38 years
- training a model in participants aged > 38 years only, to compare its performance with performance of the overall model in this group of participants, which more closely matches the age group of UK Biobank participants (reported in the Supplementary Material of the paper)
- a comparison with the standard MVPA cut-point at identifying MVPA
