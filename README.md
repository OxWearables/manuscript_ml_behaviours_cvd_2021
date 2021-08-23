# manuscript_ml_behaviours_cvd_2021

## Introduction
This folder contains code for our manuscript on the association between machine-learned movement behaviours and risk of incident cardiovascular disease in UK Biobank. 


## Outline
There are several parts to the analysis, described in separate subfolders: 
- Developing machine-learning models to classify movement behaviours, using labelled data from the CAPTURE-24 study. This is described under classifierDevelopment. 
- Applying these machine-learning models to classify the movement behaviours of participants in UK Biobank. This is described under ukbAccProcessing. 
- Preprocessing UK Biobank data on covariates and health outcomes. This is described under ukbDataPrep. 
- Running the epidemiological analysis using a Compositional Data Analysis approach. This is described under epiAnalysis. 


## Code sharing
Code is shared here with the intention of enabling the community to understand, verify, reproduce, and improve on our analyses.

Code is intended to be "as run". It has not been verified or refined for re-use. For example, some functions have arguments/use cases which were never implemented, and testing/documentation has been limited to the requirements of this particular project.

However, the text points to several software packages we have developed to enable this project and future research. These packages have more extensive documentation and flexibility.


## Errors, bugs, and queries
If you spot any errors, bugs, or anything which doesn't make sense, or have suggestions for what we could do better, please do get in touch with Rosemary Walmsley (rosemary.walmsley@gtc.ox.ac.uk, or on GitHub).
 

## Detailed notes
Submodule versions and package versions in renv.lock and environments/pip_envs/pip-env-requirements.txt should generally be as used. However, classifier development and accelerometer data processing took place with an earlier version of biobankAccelerometerAnalysis (should correspond to commit 8b2be33), an earlier version of utility scripts in clusterProcessing, and an earlier set of dependencies, though we believe that any differences should be minor.

The files runningOrder.md and allRProcessing.R describe the production of final results as seen in the paper. Note that training of machine-learning models, labelling of accelerometer data, and data extraction and prep occur prior to this. 
