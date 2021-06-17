import pandas as pd 
d = pd.read_csv("/well/doherty/projects/ukb/accelerometer_processed/group0/group0-summary.csv")
for i in range(1, 11):
    d2 = pd.read_csv("/well/doherty/projects/ukb/accelerometer_processed/group" + str(i) + "/group" + str(i) + "-summary.csv") 
    d = d.append(d2)

d.to_csv("/well/doherty/projects/ukb/accelerometer_processed/sep20-summary-all.csv")


