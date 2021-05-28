#!/bin/bash

#$ -j y
#$ -N c24_processing_cmds_270521
#$ -P doherty.prjc -q short.qe
#$ -t 1-152
#$ -o /well/doherty/users/llz512/home/paperRW2021/classifierDevelopment/inputData/c24Processed/data/clusterLogs/
#$ -pe shmem 1
#$ -wd /well/doherty/users/llz512/home/paperRW2021/biobankAccelerometerAnalysis/

module load Python/3.6.6-foss-2018b
CPU_ARCHITECTURE=$(/apps/misc/utils/bin/get-cpu-software-architecture.py)
if [[ ! $? == 0 ]]; then
	echo "Fatal error: Please send the following information to the BMRC team: Could not determine CPU software architecture on $(hostname)"
	exit 1
fi
source /well/doherty/users/llz512/home/paperRW2021/pip_envs/pip-env-270521-${CPU_ARCHITECTURE}/bin/activate
export OMP_NUM_THREADS=${NSLOTS:-1}

SECONDS=0
echo $(date +%d/%m/%Y\ %H:%M:%S)

cmdList="/well/doherty/users/llz512/home/paperRW2021/classifierDevelopment/scripts/c24_processing_cmds_270521.txt"
cmd=$(sed -n ${SGE_TASK_ID}p $cmdList)
echo $cmd
bash -c "$cmd"

duration=$SECONDS
echo "CPU time $pheno: $(($duration / 60)) min $((duration % 60)) sec"
echo $(date +%d/%m/%Y\ %H:%M:%S)
pip list > "/well/doherty/users/llz512/home/paperRW2021/classifierDevelopment/inputData/c24Processed/data/clusterLogs/c24_processing_cmds_270521_${JOB_ID}_"`date +%Y-%m-%d-%H%M%S`"_pip_environment.txt"
printenv > "/well/doherty/users/llz512/home/paperRW2021/classifierDevelopment/inputData/c24Processed/data/clusterLogs/c24_processing_cmds_270521_${JOB_ID}_"`date +%Y-%m-%d-%H%M%S`"_run_environment.txt"
