#!/bin/sh

#SBATCH --nodes=1
##SBATCH --ntasks=7
##SBATCH --ntasks-per-node=4
#SBATCH --time=00:05:00
##SBATCH --mem=4000
##SBATCH --exclusive
#SBATCH --partition=moorcroft_6100

msrc='/n/moorcroftfs2/dscott/ed_tools_nm_rewrite/test_sbatch_srun/'

echo "Starting at `date`"
echo "Running on hosts: $SLURM_NODELIST"
echo "Running on $SLURM_NNODES nodes."
echo "Running on $SLURM_NPROCS processors."
echo "Current working directory is `pwd`"

matlab -nodisplay -nosplash -r addpath\(genpath\(\'${msrc}\'\)\),do_parallel_jobs\(\),exit 1>out.txt 2>out.err 

echo "Program finished with exit code $? at: `date`"

