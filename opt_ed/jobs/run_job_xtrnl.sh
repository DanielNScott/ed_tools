#!/bin/sh

# This script should recieve the following 3 inputs:
job_num=${1}
niter=${2}
proc_loc=${3}

# The job folder location is a derivative of these.
job_loc=$proc_loc'/job_'$job_num

# A few vars contain single quotes, which need to be removed. These will be used in this
# script, but the originals will be passed to run_job.m, because that is what they're
# formatted for.
job_num_safe=${job_num//"'"/}
niter_safe=${niter//"'"/}
proc_loc_safe=${proc_loc//"'"/}
job_loc_safe=${job_loc//"'"/}

echo "---------------------- Header from run_job_xntrl.sh ---------------------------"
echo "run_job_xtrnl.sh sees the following variables:"
echo " "
echo " job_num:  ${job_num}"
echo "   niter: ${niter}"
echo "proc_loc: ${proc_loc}"
echo " job_loc: ${job_loc}"
echo " "
echo " job_num_safe: ${job_num_safe}"
echo "   niter_safe: ${niter_safe}"
echo "proc_loc_safe: ${proc_loc_safe}"
echo " job_loc_safe: ${job_loc_safe}"
echo " "
echo "The first 3 should be the inputs to this script as well as to run_job.m"
echo "-------------------------------------------------------------------------------"


#----- Set paths for matlab and template --------------------------------------------------#
path_tools='/n/moorcroftfs4/dscott/ed_tools_dev/'

rm -f out_m.txt out_m.err out_ed.txt out_ed.err

#----- Iteratively run and process --------------------------------------------------------#
iter=1
while [  $iter -le $niter_safe ]; do
   echo " "
   echo "The run_job_xtrnl.sh iteration is $iter."

   while [ ! -f $job_loc_safe'/run_flag.txt' ]; do
      sleep 10
   done
   
   echo "File $job_loc_safe/run_flag.txt found by run_job_xtrnl.sh."
   echo "Proceeding with job loop." 
   
   cp $job_loc_safe'/config.xml' ./

   echo " "
   echo "--------------------- Copying ./config.xml to Output ------------------------"
   cat ./config.xml
   echo " "
   echo "------------------------------ End of File ----------------------------------"

   # Run the model.
   echo "Running the model..."
   ./ed 1>>out_ed.txt 2>>out_ed.err

   # Process the output.
   matlab -nodisplay -nosplash -r addpath\(genpath\(\'${path_tools}\'\)\),run_job\(${job_num},1,${proc_loc}\),exit 1>>out_m.txt 2>>out_m.err
  
   # Copy the stdout and stderr off node-local scratch
   cp out_ed.txt ${job_loc_safe}/out_ed.txt
   cp out_ed.err ${job_loc_safe}/out_ed.err
   cp out_m.txt ${job_loc_safe}/out_m.txt
   cp out_m.err ${job_loc_safe}/out_m.err
   cp out.txt ${job_loc_safe}/out.txt
   cp out.err ${job_loc_safe}/out.err
   
   let iter=$iter+1 
done


