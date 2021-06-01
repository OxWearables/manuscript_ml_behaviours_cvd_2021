import pandas as pd
import os 

d = []
for filename in os.listdir("/well/doherty/users/llz512/home/paperRW2021/classifierDevelopment/inputData/c24Processed/data/epoch/"): 
    d_here = pd.read_csv("/well/doherty/users/llz512/home/paperRW2021/classifierDevelopment/inputData/c24Processed/data/epoch/" + filename, compression = "gzip", header = 0, index_col = None)
    d_here[["participant"]] = filename.rstrip("-epoch.csv.gz")
    d.append(d_here)

df = pd.concat(d, axis = 0, ignore_index = True)
df.to_csv("/well/doherty/users/llz512/home/paperRW2021/classifierDevelopment/inputData/c24Processed/c24-280521.csv") 
print(df.head())

