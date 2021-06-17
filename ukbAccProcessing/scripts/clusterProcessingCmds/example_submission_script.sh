#$ -j y
#$ -N group0-sep20-processCmds
#$ -P doherty.prjc -q short.qe
#$ -t 1-10000
#$ -o /well/doherty/projects/ukb/accelerometer_processed/group0/clusterLogs/
#$ -pe shmem 1
#$ -cwd
#$ -V

export OMP_NUM_THREADS=${NSLOTS:-1}

SECONDS=0
echo $(date +%d/%m/%Y\ %H:%M:%S)

cmdList="group0-sep20-processCmds.txt"
cmd=$(sed -n ${SGE_TASK_ID}p $cmdList)
echo $cmd
bash -c "$cmd"

duration=$SECONDS
echo "CPU time $pheno: $(($duration / 60)) min $((duration % 60)) sec"
echo $(date +%d/%m/%Y\ %H:%M:%S)
