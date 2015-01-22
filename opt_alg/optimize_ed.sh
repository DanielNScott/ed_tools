#!/bin/sh

#----- Set paths for Misc_Routines and Opt_Alg_vX.X --------------------------------------------------#
mpath='/n/moorcroftfs2/dscott/Misc_Routines/'
opath='/n/moorcroftfs2/dscott/Opt_Alg_v2.0/'
here=`pwd`

#----- Run Matlab -------------------------------------------------------------------------#
echo "Running matlab..."
matlab -nodisplay -nosplash -r addpath\(genpath\(\'${mpath}\'\)\),addpath\(genpath\(\'${opath}\'\)\),optimize_ed\(\'$1\'\)\;,exit

echo "optimize_ed.sh has finished."
