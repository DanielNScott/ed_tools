#!/bin/sh

#----- Set paths for matlab and template --------------------------------------------------#
path_tools='/n/moorcroftfs2/dscott/ed_tools_dev/' #

#----- Run Matlab -------------------------------------------------------------------------#
matlab -nojvm -nodisplay -nosplash -r addpath\(genpath\(\'${path_tools}\'\)\),run_job_smnt\(${1},${2}\),exit
