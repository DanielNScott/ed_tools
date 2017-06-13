## Overview
This repository contains most of my tools for post processing output, optimizing the model, and graphing stuff.

## Directory Contents   
matlab_central - images of required libraries.   
misc_routines - misc. small matlab utilities I wrote   
opt_ed - ed optimization program   
opt_utils - various related pieces, such as algorithm prototypes   
plotting - scripts for plotting, see plot_general & plot_all_opt esp.   
proc_obs - pre-processing for getting observational data into useful formats   
proc_out - post-processing for dealing with ED output   
smnt_ed - attempt at using spearmint (global bayesian black box opt) for ed   
struct - utilities for easy manipulatiosn of matlab 'structure' data types   
time_utils - lots of misc. stuff for dealing with time   

## Things to See...
...if you are trying to get the big picture.   
 - ed_tools/opt_ed/driver/optimize_ed.m
 - ed_tools/proc_out/import_poly.m
 - ed_tools/plotting/plot_opt/plot_all_opt.m

These files are good places to start if you want to crawl the **optimization code**, understand the **ed output read**, and the **optimization plotting** respectively.
