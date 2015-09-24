#!/bin/sh

#------------------------------------------------------------------------------------------#
#  README:
#     The following #SBATCH statements are NOT comments! They configure sbatch! 
#     Additionally, lines 15-19 are manipulated by SPAWN_POLYS.SH to contain valid inputs.
#------------------------------------------------------------------------------------------#

#SBATCH --ntasks=1               # Number of cores
#SBATCH --nodes=1                # Number of nodes to use
#SBATCH --cpus-per-task=1        # Number of cpus to use per task
#SBATCH -t 0                     # Runtime in minutes
#SBATCH -p partition             # Partition to submit to
#SBATCH --mem=1000               # Memory required per node in MB
#SBATCH -J job_name              # Job Name 
#------------------------------------------------------------------------------------------#

#----- Submitting the job -------------------------------------------------------------
run_opt.sh 1>out.txt 2>out.err
#------------------------------------------------------------------------------------------#

