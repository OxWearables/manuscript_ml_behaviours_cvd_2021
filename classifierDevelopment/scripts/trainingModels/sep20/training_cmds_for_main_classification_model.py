import accelerometer

# Note: the branch of the repo being used is 'sep20Runs'

accelerometer.accClassification.trainClassificationModel( "/well/doherty/projects/capture24/annotations/sep20-c24-modvig-light-sed-sleep.csv", 
                featuresTxt="activityModels/new_rot_inv_features.txt", 
                            rfTrees=100, rfThreads=1, outputModel = "activityModels/sep20.tar" , testParticipants = None)
