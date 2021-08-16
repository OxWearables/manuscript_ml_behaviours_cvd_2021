# manuscript_ml_behaviours_cvd_2021

## Introduction
This folder contains code for our manuscript on the association between machine-learned movement behaviours and risk of incident cardiovascular disease in UK Biobank. 


## Outline
There are several parts to the analysis, described in separate subfolders: 
- Developing machine-learning models to classify movement behaviours, using labelled data from the CAPTURE-24 study. This is described under classifierDevelopment. 
- Applying these machine-learning models to classify the movement behaviours of participants in UK Biobank. This is described under ukbAccProcessing. 
- Preprocessing UK Biobank data on covariates and health outcomes. This is described under ukbDataPrep. 
- Running the epidemiological analysis using a Compositional Data Analysis approach. This is described under epiAnalysis


## Errors, bugs, and queries
If you spot any errors, bugs, or anything which doesn't make sense, or have suggestions for what we could do better, please do get in touch with Rosemary Walmsley (rosemary.walmsley@gtc.ox.ac.uk, or on GitHub).

 
## Notes
In general, the versions of submodules and the package versions specified in the relevant R and Python lockfiles are those used for processing. However, classifier development and accelerometer data processing took place with an earlier version of biobankAccelerometerAnalysis, which should correspond to commit 8b2be33, an earlier version of the utility scripts in clusterProcessing, and an earlier set of dependency packages. However, we believe that changes to biobankAccelerometerAnalysis and dependencies on the specifics of dependency packages should be sufficiently minor that the most recent versions of relevant packages can be used.

The files runningOrder.md and allRProcessing.R describe the production of final results as seen in the paper. Note that training of machine-learning models, labelling of accelerometer data, and data extraction and prep occur prior to this. 
