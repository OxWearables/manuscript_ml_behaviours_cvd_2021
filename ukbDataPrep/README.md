# ukbDataPrep

This subfolder contains materials related to preprocessing and merging UK Biobank data.

Data preparation of UK Biobank data used the [ukb_download_and_prep_template tool](https://github.com/activityMonitoring/ukb_download_and_prep_template) and [its documentation](https://ukb-download-and-prep-template.readthedocs.io/en/latest/), alongside UK Biobank's data download helper functions.

 
## Automated extraction, merging, and recoding of variables
The first step is to get a merged file (`participant.csv`) containing the required UK Biobank columns, recoded to meaningful categories as appropriate, and also containing relevant health outcomes data. Specifically:

Columns were extracted 01.06.21 using: 
`../ukb_download_and_prep_template/download/helpers/linux_tools/ukbconv inputData/ukb41733.enc_ukb csv -ihelpers/analysisCols2705.txt`  

HES files were merged on 29.05.21 using: 
`python ../ukb_download_and_prep_template/download/download_health_data/mergeHESfiles.py inputData/hesin.txt inputData/hesin_diag.txt inputData/hesin_all.csv`

A columns file was autogenerated on 01.06.21 using: 
`python ../ukb_download_and_prep_template/writeColumnsFile.py --columnsFile helpers/analysisCols2705.txt`

The columns.json file generated was subsequently moved to helpers and amended to: 
- Include multiple array indices for: 6138 (qualifications, 0-5), 6150 (vascular heart problems diagnosed by doctor, 0-3), 6153 (medication, 0-3), 6177 (medication, 0-2)
- Remove columns unavailable to us: 26429, 22040, 3581, 1498

The data was then processed using: 
`python ../ukb_download_and_prep_template/filterUKB.py inputData/ukb41733.csv -o inputData/ukb41733_recoded_010621.csv --columnsFile helpers/columns.json --datafile ../ukb_download_and_prep_template/Data_Dictionary_Showcase.csv --codefile ../ukb_download_and_prep_template/Codings_Showcase.csv`

`python ../ukb_download_and_prep_template/addNewHES.py inputData/ukb41733_recoded_010621.csv inputData/hesin_all.csv inputData/participant.csv helpers/icdGroups2905.json --incident_prevalent True --date_column EndTimWear`

An additional processing was run on 14.01.2022 to update the negative control analysis: 
`python ../ukb_download_and_prep_template/addNewHES.py inputData/ukb41733_recoded_010621.csv inputData/hesin_all.csv inputData/participant_new_nc_20220114.csv helpers/icdGroupsUpdateNC.json --incident_prevalent True --date_column EndTimWear`

## Additional processing 
The second step is to carry out additional preprocessing, including that not directly supported by the `ukb_download_and_prep_template` tool. 

This is described in `scripts/preprocessing.R` (includes description). 

It includes: 
- Excluding participants who have withdrawn from the UK Biobank between data collection and analysis. 
- Performing exclusions, as described in the manuscript, for data quality (calibration, wear time, clips, unrealistic values) and prior disease.
- Combining data on deaths with the other health outcomes data to produce overall censoring variables for the different outcomes considered. This is quite involved as the death and health outcome data have different censoring dates, which also differ between the nations of the UK.  
- Recategorising variables to categorisation used in the final analyses. 
- Performing exclusions in preparation for sensitivity analyses.

