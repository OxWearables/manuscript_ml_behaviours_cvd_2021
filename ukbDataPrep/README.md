# ukbDataPrep

This subfolder contains materials related to preprocessing and merging UK Biobank data.

Columns were extracted 29.05.21 using: 
`../ukb_download_and_prep_template/download/helpers/linux_tools/ukbconv inputData/ukb41733.enc_ukb csv -ianalysisCols2705.txt`

HES files were merged on 29.05.21 using: 
`python ../ukb_download_and_prep_template/download/download_health_data/mergeHESfiles.py inputData/hesin.txt inputData/hesin_diag.txt inputData/hesin_all.csv`
