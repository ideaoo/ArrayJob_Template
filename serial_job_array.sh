#!/bin/bash

### slurm job array是從array每個entry為出發，這個檔案內設定的參數都是控制個別子工作的設定，並不是整體總消耗資源的設定。
#SBATCH --job-name MODEL3               # Job name
#SBATCH --output %x-%A_%a.out         # Name of stdout output file (%x expands to jobname, %j expands to jobId)

###以下配置是為了個別serial job配置
###以下示範用了srun -N 1 -n 1將許多serial job 包裝在一個parallel job
###wait是重點一定要加
###SBATCH --nodes=2                  #這邊指定的比1大的數字會造成浪費
#SBATCH --partition ct2k
#SBATCH --account GOV108018
#SBATCH --cpus-per-task=14          # Without this option, the controller will just try to allocate one processor per task.
#SBATCH --ntasks=160
#SBATCH --ntasks-per-node=4       #加上這行可以確保完整使用節點不跟人共用，除了最後一個節點
###SBATCH --array=0-9
###SBATCH --exclusive=user
###SBATCH --distribution=block


 
echo "Running on hosts: $SLURM_NODELIST"
echo "Running on $SLURM_NNODES nodes."
echo "Running $SLURM_NTASKS tasks."
echo "$SLURM_MPI_TYPE"
SUBMIT_FILE=`scontrol show job $SLURM_JOB_ID | grep "Command=" | awk 'BEGIN {FS="="}; {print $2}'`
#echo $SUBMIT_FILE
#echo ${SUBMIT_FILE##/*/}
#echo "$SLURM_SUBMIT_DIR/$SLURM_JOB_ID.debug"
#cp $SUBMIT_FILE $SLURM_SUBMIT_DIR/3d/run_0/neuron_${SLURM_ARRAY_TASK_ID}/$SLURM_JOB_ID.debug

echo "now processing task id:: ${SLURM_ARRAY_TASK_ID} on ${SLURM_JOB_NODELIST} "

echo "Your job starts at `date`"

export DISPLAY=localhost:0
export EXE=/work/p00sim00/envs/ovito4/python3 




for i in {0..80001..500}
do
  
  srun -N 1 -n 1 $EXE  classification.py  ${i}  pre_size3/part${i} &
	

done
wait

echo "Your job completed at  `date` "
