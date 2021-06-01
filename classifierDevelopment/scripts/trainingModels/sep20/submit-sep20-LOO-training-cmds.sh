#$ -j y
#$ -N sep20-LOO-training-cmds
#$ -P doherty.prjc -q short.qe
#$ -t 1-152
#$ -o clusterLogsLOO_sep20
#$ -pe shmem 1
#$ -cwd
#$ -V

export OMP_NUM_THREADS=${NSLOTS:-1}

SECONDS=0
echo $(date +%d/%m/%Y\ %H:%M:%S)

cmdList="sep20-LOO-training-cmds.txt"
cmd=$(sed -n ${SGE_TASK_ID}p $cmdList)
echo $cmd
bash -c "$cmd"

duration=$SECONDS
echo "CPU time $pheno: $(($duration / 60)) min $((duration % 60)) sec"
echo $(date +%d/%m/%Y\ %H:%M:%S)
