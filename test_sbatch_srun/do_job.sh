#!/bin/sh

msrc='/n/moorcroftfs2/dscott/ed_tools_nm_rewrite/test_sbatch_srun/'

matlab -nodisplay -nosplash -r addpath\(genpath\(\'${msrc}\'\)\),do_job\(\'${1}\'\),exit 1>out.txt 2>out.err 