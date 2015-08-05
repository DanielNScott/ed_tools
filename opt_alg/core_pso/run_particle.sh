#!/bin/sh

#------------------------------------------------------------------------------------------#
#  README:
#     The following #SBATCH statements are NOT comments! They configure sbatch! 
#     Additionally, lines 15-19 are manipulated by SPAWN_POLYS.SH to contain valid inputs.
#------------------------------------------------------------------------------------------#

#SBATCH -n 1               # Number of cores
#SBATCH -t 0               # Runtime in minutes
#SBATCH -p moorcroft_6100  # Partition to submit to
#SBATCH --mem=400          # Memory required per node in MB
#SBATCH -J particle_1 # Job Name 

#----- Submitting the job -------------------------------------------------------------
export OMP_NUM_THREADS=1
ulimit -s unlimited
#ed 1>out.txt 2>out.err

#----- Set paths for matlab and template --------------------------------------------------#
path_tools='/n/moorcroftfs2/dscott/ed_tools/'                     # Misc. Routines Path
here=`pwd`                                                        # Where this file is 

#----- Run Matlab -------------------------------------------------------------------------#
#echo "Running matlab..."
matlab -nodisplay -nosplash -r addpath\(genpath\(\'${path_tools}\'\)\),do_pso_task\(\'${1}\',\'${2}\',\'${3}\'\),exit 1>out.txt 2>out.err

