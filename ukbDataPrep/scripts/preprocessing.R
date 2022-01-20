# LOAD TOOLS===========================================================================================
library("data.table")
library("plyr")
library("gtools")

# READ IN DEATH DATA=============================================================================================
death <-
  read.csv("ukbDataPrep/inputData/death.txt",
           sep = "\t")
death_cause <-
  read.csv("ukbDataPrep/inputData/death_cause.txt",
           sep = "\t")
death_cause <-
  death_cause[, c("eid", "arr_index", "level", "cause_icd10")]

## Note a small number of participants have multiple death records.
## This seems to occur almost exclusively among Scottish participants.
## In these records, both records seem to be associated with the same date.
## Therefore, we only use one index per participant
n_old <- nrow(death)
death <- death[death$ins_index == 0,]
n_new <- nrow(death)
print(paste0("There were ", n_old - n_new , " duplicate death records"))

# READ IN PARTICIPANT DATA=============================================================================================
participant <-
  fread(
    "ukbDataPrep/inputData/participant_new_nc_20220114.csv",
    stringsAsFactors = FALSE,
    data.table = FALSE,
    check.names = TRUE,
    tz = ""
  ) # The data.table argument ensures read as data frame, check.names makes sure colnames syntactically valid

# PERFORM WITHDRAWALS============================================================================================
w <-
  read.csv("ukbDataPrep/inputData/withdrawals-feb21.csv",
           header = FALSE)
participant <- participant[!(participant$eid %in% w$V1), ]

# RESTRICT TO ONLY PARTICIPANTS WITH ACCELEROMETER DATA=============================================================================================
participant <-
  participant[as.character(participant$EndTimWear) != "", ]

participant <- participant[!is.na(participant$EndTimWear) , ]

# READ IN ACCELEROMETER DATA==============================================================================================
acc <- fread(
  "ukbDataPrep/inputData/ukb-acc-sep.csv",
  stringsAsFactors = FALSE,
  data.table = FALSE,
  check.names = TRUE,
  tz = ""
)

# MERGE===============================================================================================
all <- merge(participant, acc, by = "eid", all.x = TRUE)

# SETUP TABLE TO DESCRIBE EXCLUSIONS===============================================================================================
exclusions <- data.frame(matrix(nrow = 0, ncol = 3))
colnames(exclusions) <-
  c("Exclusion", "Number_excluded", "Number_remaining")
exclusions <-
  rbind(
    exclusions,
    data.frame(
      "Exclusion" = "Starting number",
      "Number_excluded" = NA,
      "Number_remaining" = nrow(all)
    )
  )

# REMOVE PARTICIPANTS WITH UNREALISTIC ACC DATA=============================================================================================
# TODO DISCUSS
# Use SHOWCASE VARIABLES FOR EXCLUSIONS

exc <- all[(all$DatQualGoodCalibr != "Yes") , ]
all <-
  all[(all$DatQualGoodCalibr == "Yes"), ]
exclusions <-
  rbind(
    exclusions,
    data.frame(
      "Exclusion" = "Acc data could not be calibrated UKB",
      "Number_excluded" = nrow(exc),
      "Number_remaining" = nrow(all)
    )
  )

exc <-
  all[(all$ReadExcess...8GravCalibr > 0.01 * all$TotalDataRead) |
        (all$ReadExcess...8GravCalibr.1 > 0.01 * all$TotalDataRead), ]
all <-
  all[(all$ReadExcess...8GravCalibr <= 0.01 * all$TotalDataRead) &
        (all$ReadExcess...8GravCalibr.1 <= 0.01 * all$TotalDataRead), ]
exclusions <-
  rbind(
    exclusions,
    data.frame(
      "Exclusion" = "More than 1% clips before/after calibration",
      "Number_excluded" = nrow(exc),
      "Number_remaining" = nrow(all)
    )
  )

exc <- all[(all$DatQualGoodWearTim != "Yes"), ]
all <-
  all[(all$DatQualGoodWearTim == "Yes"), ]
exclusions <-
  rbind(
    exclusions,
    data.frame(
      "Exclusion" = "Poor wear time UKB",
      "Number_excluded" = nrow(exc),
      "Number_remaining" = nrow(all)
    )
  )


exc <- all[(all$acc.overall.avg >= 100), ] # This doesn't cope well with the two people who have NA values in acc BUT the numbers in the paper are all correct
all <- all[(all$acc.overall.avg < 100), ] # This doesn't cope well with the two people who have NA values in acc
exclusions <-
  rbind(
    exclusions,
    data.frame(
      "Exclusion" = "Unrealistically high acc data",
      "Number_excluded" = nrow(exc),
      "Number_remaining" = nrow(all)
    )
  )

exc <- all[(is.na(all$MVPA)), ]
all <- all[!(is.na(all$MVPA)), ]
exclusions <-
  rbind(
    exclusions,
    data.frame(
      "Exclusion" = "File failed to process",
      "Number_excluded" = nrow(exc),
      "Number_remaining" = nrow(all)
    )
  )

# REMOVE PREVALENT CASES===========================================================================================
## In HES data:
exc <- all[all$CVD.prevalent != 0, ]
all <- all[all$CVD.prevalent == 0, ]

exclusions <-
  rbind(
    exclusions,
    data.frame(
      "Exclusion" = "Prevalent HES-recorded CVD",
      "Number_excluded" = nrow(exc),
      "Number_remaining" = nrow(all)
    )
  )

## Self-reported at baseline:
exc <-
  all[((
    all$Vascular.heartProblemDiagnosDoct_0_0 %in% c("Heart attack", "Stroke")
  ) |
    (
      all$Vascular.heartProblemDiagnosDoct_0_1 %in% c("Heart attack", "Stroke")
    ) |
    (
      all$Vascular.heartProblemDiagnosDoct_0_2 %in% c("Heart attack", "Stroke")
    ) |
    (
      all$Vascular.heartProblemDiagnosDoct_0_3 %in% c("Heart attack", "Stroke")
    )
  ), ]

all <-
  all[!((
    all$Vascular.heartProblemDiagnosDoct_0_0 %in% c("Heart attack", "Stroke")
  ) |
    (
      all$Vascular.heartProblemDiagnosDoct_0_1 %in% c("Heart attack", "Stroke")
    ) |
    (
      all$Vascular.heartProblemDiagnosDoct_0_2 %in% c("Heart attack", "Stroke")
    ) |
    (
      all$Vascular.heartProblemDiagnosDoct_0_3 %in% c("Heart attack", "Stroke")
    )
  ), ]
exclusions <-
  rbind(
    exclusions,
    data.frame(
      "Exclusion" = "Prevalent CVD at baseline",
      "Number_excluded" = nrow(exc),
      "Number_remaining" = nrow(all)
    )
  )

# MERGE MAIN DEATH DATASET============================================================================================
all <-
  merge(all, death[, c("eid", "date_of_death")], by = "eid", all.x = TRUE)
all$died <- 0
all$died[all$date_of_death != ""] <- 1

# CHECK NO DUPLICATES====================================================================================================
all <- all[!(is.na(all$eid)),]
if (nrow(all) != length(unique(all$eid))) {
  stop("There seem to be duplicates")

}

# ADD A COLUMN FOR CVD EVENTS FIRST RECORDED IN DEATH DATA ======================================================================================================
candidate <- all[(all$died == 1) & (all$CVD.incident == 0), ]
relevant_deaths <- death_cause[death_cause$eid %in% candidate$eid, ]
CVD_death <-
  relevant_deaths[apply(relevant_deaths, 1, function(x)
    any(grepl("I20|I21|I22|I23|I24|I25|I6", x))), ]
all$CVD.incident_at_death <- 0
all$CVD.incident_at_death[all$eid %in% CVD_death$eid] <- 1

# ADD A COLUMN FOR ALL CVD DEATHS ====================================================================================================
candidate_any_cv_death <- all[(all$died == 1), ]
relevant_deaths_any_cv_death <-
  death_cause[death_cause$eid %in% candidate_any_cv_death$eid, ]
CVD_death_any_cv_death <-
  relevant_deaths_any_cv_death[apply(relevant_deaths_any_cv_death, 1, function(x)
    any(grepl("I20|I21|I22|I23|I24|I25|I6", x))), ]

# ADD A COLUMN FOR NC EVENTS first recorded in death data======================================================================================================
candidate_nc <- all[(all$died == 1) & (all$accidents_new == ""), ]
relevant_deaths_nc <- death_cause[death_cause$eid %in% candidate_nc$eid, ]
nc_death <- relevant_deaths_nc[apply(relevant_deaths_nc, 1, function(x)
       any(grepl("V0|V2|V3|V4|V5|V6|V7|V8|V9|W2|W3|W4|W5|W6|W7|W8|W9|X0|X1|X2|X3|X4|X5", x))), ]
all$nc.incident_at_death <- 0
all$nc.incident_at_death[all$eid %in% nc_death$eid] <- 1

# ADD CENSORING FOR MORTALITY=====================================================================================================
all$censor_mortality <- "28/02/2021"
all$follow_up_mortality <- as.Date(all$censor_mortality, "%d/%m/%Y")
all$follow_up_mortality[all$died == 1] <-
  pmin(all$follow_up_mortality[all$died == 1],
       as.Date(all$date_of_death[all$died == 1],  "%d/%m/%Y"))
all$any_death_from_cvd <- 0
all$any_death_from_cvd[(all$eid %in% CVD_death_any_cv_death$eid) &
                         (all$follow_up_mortality != as.Date(all$censor_mortality, "%d/%m/%Y"))] <- 1

# CREATE COLUMN OF COUNTRY===========================================================================================================
all$country <- "England"
all$country[(all$UkBiobankAssessCent == "Edinburgh") |
              (all$UkBiobankAssessCent == "Glasgow")] <- "Scotland"
all$country[(all$UkBiobankAssessCent == "Cardiff") |
              (all$UkBiobankAssessCent == "Swansea") |
              (all$UkBiobankAssessCent == "Wrexham")] <- "Wales"

# ADD CENSORING DATES FOR HES DATA BY COUNTRY============================================================================================================================
all$censored <- "28/02/2021"
all$censored[all$country == "Wales"] <- "28/02/2018"

# ADD DATE OF LAST COMPLETE FOLLOW UP FOR CVD ( WITH COMPLETE FOLLOW UP IN ALL RECORDS)=================================================================================================================================
all$follow_up <-
  as.Date(all$censored, "%d/%m/%Y") # censor at this date as after this date while there may be data it is incomplete
all$follow_up[all$CVD.incident == 1] <-
  pmin(all$follow_up[all$CVD.incident == 1], as.Date(all$CVD[all$CVD.incident == 1], "%Y-%m-%d"))
all$follow_up[all$died == 1] <-
  pmin(all$follow_up[all$died == 1], as.Date(all$date_of_death[all$died == 1],  "%d/%m/%Y"))

# ADD IN A CVD STATUS BIOMARKER AT EXIT====================================================================================================================================
all$CVD_event <- 0

# First process people who have incident CVD at death
all_CVD_incident_at_death <- all[all$CVD.incident_at_death == 1, ]
CVs_at_death <-
  all_CVD_incident_at_death$eid[all_CVD_incident_at_death$follow_up == as.Date(all_CVD_incident_at_death$date_of_death,  "%d/%m/%Y")]
all$CVD_event[all$eid %in% CVs_at_death] <- 1

# Then process everyone else. We can't just take CVD.incident as the records in fact extend past the last known record.
all_CVD_incident <- all[all$CVD.incident == 1, ]
CVs <-
  all_CVD_incident$eid[all_CVD_incident$follow_up == as.Date(all_CVD_incident$CVD,  "%Y-%m-%d")]
all$CVD_event[all$eid %in% CVs] <- 1


# ADD IN FOLLOW UP FOR NEGATIVE CONTROL ===========================================================================================================================================
## ADD FOLLOW UP FOR NEGATIVE CONTROL - FOLLOW UP ======================================================================
all$follow_up_neg_control_acc <- as.Date(all$censored, "%d/%m/%Y")
all$follow_up_neg_control_acc[all$accidents_new.incident == 1] <- pmin(
     all$follow_up_neg_control_acc[all$accidents_new.incident == 1],
     as.Date(all$accidents_without_PA_link[all$accidents_new.incident == 1], "%Y-%m-%d")
   )
all$follow_up_neg_control_acc[all$died == 1] <-
   pmin(all$follow_up_neg_control_acc[all$died == 1],
        as.Date(all$date_of_death[all$died == 1],  "%d/%m/%Y"))

# # ADD IN A NEG CONTROL STATUS BIOMARKER AT EXIT===========================================================================================================================
all$neg_control_event_acc <- 0
# First process people who have incident NC at death
all_nc_incident_at_death <- all[all$nc.incident_at_death == 1, ]
NCs_at_death <- all_nc_incident_at_death$eid[all_nc_incident_at_death$follow_up == as.Date(all_nc_incident_at_death$date_of_death,  "%d/%m/%Y")]
all$neg_control_event_acc[all$eid %in% NCs_at_death] <- 1

# We can't just take accidents_new.incident as the records in fact extend past the last known record.
all_neg_control_acc_incident <-
   all[all$accidents_new.incident == 1, ]
NCs <-
   all_neg_control_acc_incident$eid[all_neg_control_acc_incident$follow_up_neg_control_acc == as.Date(all_neg_control_acc_incident$accidents_new,
                                                                                                      "%Y-%m-%d")]
all$neg_control_event_acc[all$eid %in% NCs] <- 1

# ADD DATE OF BIRTH===========================================================================================================================================
all$approx_dob <-
  as.Date(paste(all$YearOfBirth, all$MonthOfBirth, "15", sep = "-"),
          "%Y-%B-%d")

all$age_entry <-
  difftime(as.Date(all$EndTimWear, "%Y-%m-%d %H:%M:%S"),
           # MAY NEED TO HAVE A 'T' added
           all$approx_dob,
           units = "days")

all$age_exit <-
  difftime(all$follow_up, all$approx_dob,  units = "days")
all$neg_control_acc_exit <-
  difftime(all$follow_up_neg_control_acc, all$approx_dob,  units = "days")
all$age_exit_mortality <-
  difftime(all$follow_up_mortality, all$approx_dob,  units = "days")

all$time_in_study <- as.numeric(all$age_exit - all$age_entry)
all$years_in_study <- all$time_in_study / (365.25)

# CHECK NOONE ENTERED BEFORE EXIT
if (length(all$eid[all$age_entry > all$age_exit]) != 0) {
  stop("Some participants seem to have entered the study after they exited it")
}

# ADD COMPOSITE DIETARY VARS==========================================================================================================
# FRUIT AND VEG
all$FreshFruitIntak[all$FreshFruitIntak == -10] <- 0.5
all$CookVegetIntak[all$CookVegetIntak == -10] <- 0.5
all$SaladRawVegetIntak[all$SaladRawVegetIntak == -10] <- 0.5

all$fruit_and_veg <- NA
all$fruit_and_veg[(all$FreshFruitIntak == -1) |
                    (all$CookVegetIntak == -1) |
                    (all$SaladRawVegetIntak == -1)] <- "DNK"

all$fruit_and_veg[all$FreshFruitIntak == -3 |
                    all$CookVegetIntak == -3 |
                    all$SaladRawVegetIntak == -3] <- "PNA"

all$fruit_and_veg[is.na(all$fruit_and_veg)] <-
  all$FreshFruitIntak[is.na(all$fruit_and_veg)] + all$CookVegetIntak[is.na(all$fruit_and_veg)] + all$SaladRawVegetIntak[is.na(all$fruit_and_veg)]

all$fruit_and_veg[all$fruit_and_veg == "DNK" |
                    all$fruit_and_veg == "PNA"] <- NA

all$fruit_and_veg_cats <-
  cut(
    as.numeric(all$fruit_and_veg),
    c(-10,  2.99,   4.99, 7.99, 1000),
    c(
      "Less than 3 servings/day",
      "3-4.9 servings/day",
      "5-7.9 servings/day",
      "8+ servings/day"
    )
  )

# MEAT
all$lamb <-
  plyr::mapvalues(
    all$Lamb.muttonIntak,
    from = c(
      "Never",
      "Less than once a week",
      "Once a week",
      "2-4 times a week",
      "Do not know",
      "5-6 times a week",
      "",
      "Prefer not to answer",
      "Once or more daily"
    ),
    to =  c(0, 0.5, 1, 3, NA, 5.5, NA, NA, 7)
  )
all$pork <-
  plyr::mapvalues(
    all$PorkIntak,
    from = c(
      "Never",
      "Less than once a week",
      "Once a week",
      "2-4 times a week",
      "Do not know",
      "5-6 times a week",
      "",
      "Prefer not to answer",
      "Once or more daily"
    ),
    to =  c(0, 0.5, 1, 3, NA, 5.5, NA, NA, 7)
  )
all$beef <-
  plyr::mapvalues(
    all$BeefIntak,
    from = c(
      "Never",
      "Less than once a week",
      "Once a week",
      "2-4 times a week",
      "Do not know",
      "5-6 times a week",
      "",
      "Prefer not to answer",
      "Once or more daily"
    ),
    to =  c(0, 0.5, 1, 3, NA, 5.5, NA, NA, 7)
  )
all$red_meat <-
  as.numeric(all$lamb) + as.numeric(all$pork) + as.numeric(all$beef)
all$red_meat_cats <-
  cut(
    all$red_meat,
    c(-10, 0.99, 1.99,   3.99, 30),
    c(
      "Less than 1 time/week",
      "1-1.9 times/week",
      "2-3.9 times/week",
      "4+ times/week"
    )
  )

all$processed_meat_numeric <-
  plyr::mapvalues(
    all$ProcessMeatIntak,
    from = c(
      "Never",
      "Less than once a week",
      "Once a week",
      "2-4 times a week",
      "Do not know",
      "5-6 times a week",
      "",
      "Prefer not to answer",
      "Once or more daily"
    ),
    to =  c(0, 0.5, 1, 3, NA, 5.5, NA, NA, 7)
  )

all$red_and_processed_meat <-
  all$red_meat + as.numeric(all$processed_meat_numeric)
all$red_and_processed_meat_cats <-
  cut(
    all$red_and_processed_meat,
    c(-10, 0.99, 2.99,   4.99, 30),
    c(
      "Less than 1 time/week",
      "1-2.9 times/week",
      "3-4.9 times/week",
      "5+ times/week"
    )
  )

# OILY FISH
all$oily_fish <-
  plyr::mapvalues(
    all$OiliFishIntak,
    from = c(
      "Never",
      "Less than once a week",
      "Once a week",
      "2-4 times a week",
      "Do not know",
      "5-6 times a week",
      "",
      "Prefer not to answer",
      "Once or more daily"
    ),
    to =  c(
      "< 1 time/week",
      "< 1 time/week",
      "1 time/week",
      "2-4 times/ week",
      NA,
      "More than 4 times/week",
      NA,
      NA,
      "More than 4 times/week"
    )
  )

# RECODE ETHNICITY ===============================================================================================================================================
all$ethnicity <-
  plyr::mapvalues(
    all$EthnicBackground,
    c(
      "British" ,
      "Any other white background",
      "Irish",
      "White and Asian",
      "Other ethnic group",
      "Caribbean",
      "Chinese",
      "Indian",
      "Pakistani",
      "White and Black African",
      "Any other mixed background",
      "African",
      "White and Black Caribbean",
      "Prefer not to answer",
      "White",
      "Do not know" ,
      "Any other Black background",
      "Any other Asian background",
      "" ,
      "Bangladeshi",
      "Mixed",
      "Asian or Asian British",
      "Black or Black British"
    ),
    c(
      "White" ,
      "White",
      "White",
      "Mixed_and_other",
      "Mixed_and_other",
      "Black",
      "Mixed_and_other",
      "Asian",
      "Asian",
      "Mixed_and_other",
      "Mixed_and_other",
      "Black",
      "Mixed_and_other",
      NA,
      "White",
      NA ,
      "Black",
      "Asian",
      NA ,
      "Asian",
      "Mixed_and_other",
      "Asian",
      "Black"
    )
  )

# RECODE EDUCATION ==========================================================================
all$education_cats <- "empty"
for (i in 0:5) {
  col <- paste0("Qualif_0_", i)
  print(col)
  print(head(all[, col]))
  all$education_cats[all[, col] == "College or University degree"] <-
    "Higher education"
  all$education_cats[(all$education_cats != "Higher education") &
                       (
                         all[, col] %in% c(
                           "A levels/AS levels or equivalent",
                           "NVQ or HND or HNC or equivalent" ,
                           "Other professional qualifications eg: nursing, teaching"
                         )
                       )] <-
    "Further, professional or vocational education"
  all$education_cats[(!(
    all$education_cats %in% c(
      "Higher education",
      "Further, professional or vocational education"
    )
  )) & (all[, col] %in% c(
    "CSEs or equivalent",
    "None of the above" ,
    "O levels/GCSEs or equivalent"
  ))] <- "School leaver"
}
all$education_cats[all$education_cats == "empty"] <- NA


# RECODE SMOKING, ALCOHOL =====================================================================

all$smoking <- all$SmokeStatus
all$smoking[all$smoking == "" |
              all$smoking == "Prefer not to answer"] <- NA

all$alcohol <-
  plyr::mapvalues(
    all$AlcoholIntakFrequenc,
    from = c(
      "Never",
      "Three or four times a week",
      "Daily or almost daily",
      "Once or twice a week",
      "One to three times a month",
      "Special occasions only",
      "Prefer not to answer",
      "",
      "Do not know"
    ),
    to = c(
      "Never",
      "3+ times per week",
      "3+ times per week",
      "< 3 times per week",
      "< 3 times per week",
      "< 3 times per week",
      NA,
      NA,
      NA
    )
  )
# VARIABLES FOR EXCLUSIONS=============================================================================
meds_list <- c("Blood pressure medication",
               "Cholesterol lowering medication",
               "Insulin")
all$meds <-
  all$MedCholesterolBloodPressDiabet_0_0 %in% meds_list |
  all$MedCholesterolBloodPressDiabet_0_1 %in% meds_list |
  all$MedCholesterolBloodPressDiabet_0_2 %in% meds_list |
  all$MedCholesterolBloodPressDiabetTakExogHormon_0_0 %in% meds_list |
  all$MedCholesterolBloodPressDiabetTakExogHormon_0_1 %in% meds_list |
  all$MedCholesterolBloodPressDiabetTakExogHormon_0_2 %in% meds_list |
  all$MedCholesterolBloodPressDiabetTakExogHormon_0_3 %in% meds_list
all$poor_health <- all$OveralHealthRate == "Poor"
all$any_previous_I_code <- all$all.cardiovascular.prevalent

# RELABEL OTHER VARIABLES================================================================================
all$BMI <- all$BodyMassIndex.Bmi.
all$sex <- all$Sex

# LIST COVARIATES IN CONVENIENT WAY ================================================================
# List of covariates except sex and bmi - NB THIS MATCHES ANALYSIS SCRIPT
covs <-
  c(
    "ethnicity",
    "smoking",
    "alcohol",
    "fruit_and_veg_cats",
    "red_and_processed_meat_cats",
    "oily_fish",
    "TDI_quartiles",
    "education_cats"
  )

# List of covariates for descriptive tables
covs_cat <-
  c('age_cats', 'sex', covs, 'BMI_cats')

# CATEGORISE SOME CONTINUOUS VARIABLES======================================================================================================
# Add BMI categories
all$BMI_cats <-
  cut(
    all$BMI,
    breaks = c(0, 18.5, 25, 30, 10000),
    labels = c("Underweight", "Normal weight", "Overweight", "Obese")
  )
all$BMI_cats_coarse <-
  cut(
    all$BMI,
    breaks = c(0, 25, 30, 10000),
    labels = c("Normal Weight or Underweight", "Overweight", "Obese")
  )

# Add age categories
all$age_cats <-
  cut(
    as.numeric(all$age_entry),
    breaks = 365.25 * c(0, 50, 60, 70, 80),
    labels = c("40-49", "50-59", "60-69", "70-79")
  )

# RELEVEL FACTORS====================================================================================
for (var in covs_cat[covs_cat != "TDI_quartiles"]) {
  all[, var] <- as.factor(all[, var])
}
all$ethnicity <- relevel(all$ethnicity, "White")
all$smoking <- relevel(all$smoking, "Never")
all$alcohol <- relevel(all$alcohol, "3+ times per week")
all$fruit_and_veg_cats <-
  relevel(all$fruit_and_veg_cats, "5-7.9 servings/day")
all$oily_fish <- relevel(all$oily_fish, "< 1 time/week")
all$education_cats <-
  relevel(all$education_cats, "Higher education")

# EXCLUSIONS FOR MISSING DATA ============================================================================
for (cov in c("sex", covs[covs != "TDI_quartiles"], "TownsendDeprIndexRecruit",  "BMI")) {
  print(cov)
  old <- nrow(all)
  all <- all[!(is.na(all[, cov]) | all[, cov] == ""),]
  print(old - nrow(all))
  exclusions <- rbind(
    exclusions,
    data.frame(
      "Exclusion" = paste0("Missing ", cov),
      "Number_excluded" = old - nrow(all),
      "Number_remaining" = nrow(all)
    )
  )
}


# Quartiles on included participants
all$TDI_quartiles <-
  quantcut(
    as.numeric(all$TownsendDeprIndexRecruit),
    q = 4,
    labels = c(
      "Least deprived",
      "Second least deprived",
      "Second most deprived",
      "Most deprived"
    )
  )
all$TDI_quartiles <- as.factor(all$TDI_quartiles)

# PREPARE DATASETS FOR SENSITIVITY ANALYSES FOR REVERSE CAUSATION---------------------------
# Preparation for an analysis where only follow up is removed (no additional health related factors)
all_only_fu <- all
all_only_fu$age_entry <-
  all_only_fu$age_entry + 365.25 * 2
all_only_fu <-
  all_only_fu[all_only_fu$age_entry < all_only_fu$age_exit, ]

all_sensitivity <- all_only_fu
exclusions <- rbind(
  exclusions,
  data.frame(
    "Exclusion" = paste0("Sensitivity: Removal of first 2 years of follow up"),
    "Number_excluded" = nrow(all) - nrow(all_sensitivity),
    "Number_remaining" = nrow(all_sensitivity)
  )
)

# Exclude on additional health-related factors
for (cov in c("meds", "poor_health", "any_previous_I_code")) {
  name <- paste0("all_sensitivity_", cov)
  old <- nrow(all_sensitivity)
  all_sensitivity <- all_sensitivity[!(all_sensitivity[, cov]),]
  assign(name, all_sensitivity)
  exclusions <- rbind(
    exclusions,
    data.frame(
      "Exclusion" = paste0("Sensitivity: ", cov),
      "Number_excluded" = old - nrow(all_sensitivity),
      "Number_remaining" = nrow(all_sensitivity)
    )
  )
}
# WRITE FILE DESCRIBING EXCLUSIONS =============================================================
write.csv(exclusions,
          paste0("ukbDataPrep/plots/", name_of_current_run, "exclusions.csv"))

# WRITE TO DATA FILES ===================================================================================
saveRDS(
  all,
  paste0(
    "epiAnalysis/inputData/",
    name_of_current_run,
    "_ready_to_use.RDS"
  )
)

saveRDS(
  all_only_fu,
  paste0(
    "epiAnalysis/inputData/",
    name_of_current_run,
    "_only_fu.RDS"
  )
)

saveRDS(
  all_sensitivity,
  paste0(
    "epiAnalysis/inputData/",
    name_of_current_run,
    "_sensitivity.RDS"
  )
)

