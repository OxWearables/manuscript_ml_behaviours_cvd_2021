from accelerometer import accUtils
x = [0,1,2,3,4,5,6,7,8,9, 10]
for i in x:
    accUtils.collateJSONfilesToSingleCSV("/well/doherty/projects/ukb/accelerometer_processed/group" + str(i) + "/summary/","/well/doherty/projects/ukb/accelerometer_processed/group" + str(i)+ "/group" + str(i) + "-summary.csv")
