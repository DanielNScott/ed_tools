#!/bin/sh

#------------------------------------------------------------------------------------------#
#  README:
#     The following #SBATCH statements are NOT comments! They configure sbatch! 
#     Additionally, lines 15-19 are manipulated by SPAWN_POLYS.SH to contain valid inputs.
#------------------------------------------------------------------------------------------#

#SBATCH -n 1      # Number of cores
#SBATCH -t 0       # Runtime in minutes
#SBATCH -p moorcroft_6100  # Partition to submit to
#SBATCH --mem=0          # Memory required per node in MB
#SBATCH -J r85DS_SD050 # Job Name 

#----- Submitting the job -----------------------------------------------------------------#
rm -rf oed.out oed.err out.txt out.err
here=`pwd`
settings="${here}/settings"

$here/optimize_ed $settings 1>oed.out 2>oed.err
