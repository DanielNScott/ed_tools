#!/bin/sh

#----- Set paths for matlab and template --------------------------------------------------#
path_tools='/n/moorcroftfs2/dscott/ed_tools_dev/'

#----- Run Matlab -------------------------------------------------------------------------#
matlab -nodisplay -nosplash -r addpath\(genpath\(\'${path_tools}\'\)\),run_job\(${1},${2},${3}\),exit 1>out.txt 2>out.err


