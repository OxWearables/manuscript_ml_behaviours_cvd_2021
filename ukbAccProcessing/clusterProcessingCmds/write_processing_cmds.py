from accelerometer import accUtils
for i in range(0,11): 
    accUtils.writeStudyAccProcessCmds(accDir = "/well/doherty/projects/ukb/accelerometer/group" + str(i),
                outDir = "/well/doherty/projects/ukb/accelerometer_processed/group"+ str(i),  cmdsFile='group' + str(i) +'-sep20-processCmds.txt',
                        accExt="cwa.gz", cmdOptions="--deleteIntermediateFiles False --activityModel /well/doherty/users/llz512/home/biobankAccelerometerAnalysis/activityModels/sep20.tar")
