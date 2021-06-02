import pandas as pd
trainingFile = "/well/doherty/projects/capture24/annotations/sep20-c24-modvig-light-sed-sleep-over-38s.csv"
d = pd.read_csv(trainingFile, usecols=['participant'])
pts = sorted(d['participant'].unique())

w = open('may21-LOO-training-cmds-restricted.txt','w')
for p in pts:
    cmd = "import accelerometer;"
    cmd += "accelerometer.accClassification.trainClassificationModel("
    cmd += "'" + trainingFile + "', "
    cmd += "featuresTxt='activityModels/features_list_as_used_in_sep20.txt',"
    cmd += "testParticipants='" + str(p) + "',"
    cmd += "labelCol='label',"
    cmd += "outputPredict='LOO_restricted_may21/testPredictions/testPredict-" + str(p) + ".csv',"
    cmd += "rfTrees=100, rfThreads=1)"
    w.write('python3 -c $"' + cmd + '"\n')
w.close()
# <list of processing commands written to "training-cmds.txt">
