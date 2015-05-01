#!/bin/sh

#------------------------------------------------------------------------------------------#
#  README:
#     The following #SBATCH statements are NOT comments! They configure sbatch! 
#     Additionally, lines 15-19 are manipulated by SPAWN_POLYS.SH to contain valid inputs.
#------------------------------------------------------------------------------------------#

#SBATCH -n 1               # number of tasks per node
#SBATCH -N 1               # number of nodes
#SBATCH --cpus-per-task=1  # number of cpus  per task
#SBATCH -t 0               # Runtime in minutes
#SBATCH -p moorcroft_6100  # Partition to submit to
#SBATCH --mem=0            # Memory required per node in MB
#SBATCH -J some_job_name   # Job Name 
#SBATCH --output=slurm.out # Slurm specific output file
#SBATCH --error=slurm.err  # Slurm specific output file

#----- Submitting the job -----------------------------------------------------------------#

export OMP_NUM_THREADS=1
ulimit -s unlimited

rm -rf out_ed.txt
rm -rf out_ed.err
rm -rf out_opt.txt
rm -rf out_opt.err
rm -rf config.xml

here=`pwd`
$here/call_mlab.sh ${1} 1>out_opt.txt 2>out_opt.err
