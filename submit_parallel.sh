#!/bin/bash
#SBATCH --job-name=dimer_losc_processing_array
#SBATCH --partition=compute
#SBATCH --account=csd888
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --cpus-per-task=8
#SBATCH --time=25:00:00
#SBATCH --array=0-31

module load cpu/0.15.4
module load gcc/10.2.0
module load parallel/20200822
module load openmpi/4.0.4

source ~/.bashrc
conda activate losc_env
export PYTHONPATH=${PYTHONPATH}:/home/pew018/repos/losc/build/src

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

TOTAL_JOBS=42508

PARALLEL_JOBS=$SLURM_NTASKS


JOBS_PER_ARRAY_TASK=$((TOTAL_JOBS / 32 + 1))

START=$((SLURM_ARRAY_TASK_ID * JOBS_PER_ARRAY_TASK + 1))
END=$((START + JOBS_PER_ARRAY_TASK - 1))

if [ $END -gt $TOTAL_JOBS ]; then
    END=$TOTAL_JOBS
fi

echo "Array task ${SLURM_ARRAY_TASK_ID} processing jobs from $START to $END"


process_job() {
    local job_id=$1
    echo "Processing job $job_id"

    python3 sample_pbe.py training_set.xyz $job_id $OMP_NUM_THREADS
}

export -f process_job

seq $START $END | parallel -j $PARALLEL_JOBS process_job

echo "Array task ${SLURM_ARRAY_TASK_ID} complete"