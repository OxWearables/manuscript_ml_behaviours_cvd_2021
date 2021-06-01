import pandas as pd
trainingFile = "/well/doherty/projects/capture24/annotations/sep20-c24-modvig-light-sed-sleep.csv"
d = pd.read_csv(trainingFile, usecols=['participant'])
pts = sorted(d['participant'].unique())

w = open('sep20-LOO-training-cmds.txt','w')
for p in pts:
    cmd = "import accelerometer;"
    cmd += "accelerometer.accClassification.trainClassificationModel("
    cmd += "'" + trainingFile + "', "
    cmd += "featuresTxt='activityModels/new_rot_inv_features.txt',"
    cmd += "testParticipants='" + str(p) + "',"
    cmd += "labelCol='label',"
    cmd += "outputPredict='activityModels/testPredict-" + str(p) + ".csv',"
    cmd += "rfTrees=100, rfThreads=1)"
    w.write('python3 -c $"' + cmd + '"\n')
w.close()
# <list of processing commands written to "training-cmds.txt">
