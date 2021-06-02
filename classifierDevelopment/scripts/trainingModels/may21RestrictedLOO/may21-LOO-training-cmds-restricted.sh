#!/bin/bash

#$ -j y
#$ -N may21-LOO-training-cmds-restricted
#$ -P doherty.prjc -q short.qe
#$ -t 1-72
#$ -o LOO_restricted_may21/clusterLogs2805/
#$ -pe shmem 1
#$ -cwd

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

cmdList="may21-LOO-training-cmds-restricted.txt"
cmd=$(sed -n ${SGE_TASK_ID}p $cmdList)
echo $cmd
bash -c "$cmd"

duration=$SECONDS
echo "CPU time $pheno: $(($duration / 60)) min $((duration % 60)) sec"
echo $(date +%d/%m/%Y\ %H:%M:%S)
pip list > "LOO_restricted_may21/clusterLogs2805/may21-LOO-training-cmds-restricted_${JOB_ID}_"`date +%Y-%m-%d-%H%M%S`"_pip_environment.txt"
printenv > "LOO_restricted_may21/clusterLogs2805/may21-LOO-training-cmds-restricted_${JOB_ID}_"`date +%Y-%m-%d-%H%M%S`"_run_environment.txt"
