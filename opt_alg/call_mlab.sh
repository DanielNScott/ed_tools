#!/bin/sh

#----- Set paths for matlab and template --------------------------------------------------#
path_tools='/n/moorcroftfs2/dscott/ed_tools/'                        # Path to .m files

#----- Run Matlab -------------------------------------------------------------------------#
echo "Running matlab..."
matlab -nodisplay -nosplash -r addpath\(genpath\(\'${path_tools}\'\)\),optimize_ed\(\'${1}\'\),exit

