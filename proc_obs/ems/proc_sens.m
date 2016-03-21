function [ output_args ] = proc_sens( input_args )
%PROC_SENS Summary of this function goes here
%   Detailed explanation goes here

csvread('C:\Users\Dan\moorcroft_lab\observations\harvard_forest_archives\hf-004-flux\proc\sens_hourly_2011.csv',2,0)
sens_data = ans
raw = sens_data
proc_data = raw(:,5:6)
proc_data(proc_data == -9999) = NaN

mc_sens = mc_ems_data(proc_data(:,1),proc_data(:,2),5000,'2011-01-01-00-00-00','2012-01-01-00-00-00','laprnd')
mc_sens.ym_day + mc_sens.ym_night
mc_sens.ym_day + mc_sens.ym_night/2
mc_sens.mm
mc_sens.ms
mc_sens.ms./mc_sens.mm
mc_sens.ms./mc_sens.mm*100

end