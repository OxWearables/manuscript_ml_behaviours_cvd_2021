import accelerometer

# Note: the branch of the repo being used is 'sep20Runs'

accelerometer.accClassification.trainClassificationModel( "/well/doherty/projects/capture24/annotations/sep20-c24-modvig-light-sed-sleep-over-38s.csv", 
                featuresTxt="activityModels/features_list_as_used_in_sep20.txt", 
                            rfTrees=100, rfThreads=1, outputModel = "activityModels/may20-restricted.tar" , testParticipants = None)
