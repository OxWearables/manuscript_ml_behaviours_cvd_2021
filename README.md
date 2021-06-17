# manuscript_ukb_coda_2021

## Introduction
This folder contains code used to produce the results of our manuscript on the association between machine-learned movement behaviours and risk of incident cardiovascular disease in UK Biobank. 

## Outline
The analysis depends on several tools and datasets: 
- Developing machine-learning models to classify movement behaviours, using labelled data from the CAPTURE-24 study. This is described under classifierDevelopment. 
- Applying these machine-learning models to classify the movement behaviours of participants in UK Biobank. This is described under ukbAccProcessing. 
- Preprocessing UK Biobank data on covariates and health outcomes. This is described under ukbDataPrep. 
- Running the epidemiological analysis (using a Compositional Data Analysis approach)
- The files runningOrder.md and allRProcessing.R describe the production of final results as seen in the paper. Note that training of machine-learning models and labelling of accelerometer data occurs prior to this. 

## Notes
While the aim is full analytic reproducibility, the array of tools used (including several dependency packages also on github, as well as high perfomance computing cluster processing) means it's not yet quite possible to press a button and rerun everything, even if you have the data. But, we hope that resources on all the individual sections of the analysis can be found. 

In general, the versions of submodules and the package versions specified in the relevant R and Python lockfiles are those used for processing. However, classifier development and accelerometer data processing took place with an earlier version of biobankAccelerometerAnalysis, which should correspond to commit 8b2be33, and an earlier set of dependency packages. However, we believe that any changes are sufficiently minor that the most recent versions of relevant packages can be used.

## Errors, bugs, and queries
If you spot any errors, bugs, or anything which doesn't make sense, please do get in touch with Rosemary Walmsley (rosemary.walmsley@gtc.ox.ac.uk). 


