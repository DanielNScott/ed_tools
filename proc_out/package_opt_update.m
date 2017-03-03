function [ ] = package_opt_update( old_opt_name, opt_name, obs_name )
%PACKAGE_OPT_UPDATE Summary of this function goes here
%   Detailed explanation goes here

load(old_opt_name);

state_ref = hist.state_ref;
stats_ref = hist.stats.ref;
pred_ref  = hist.pred_ref;

load(opt_name);

hist.pred_ref  = pred_ref;
hist.state_ref = state_ref;
hist.stats.ref = stats_ref;

mkdir opt;
cd    opt;
save([opt_name]);

plot_all_opt(opt_name,['../' obs_name],1)

close all;
cd    ../;

if 0
load(['./opt/' opt_name])

blah.ref  = hist.pred_ref;
blah.best = hist.pred_best;

mkdir general; cd general;
plot_general(blah,[1:8],0,'TCH',1)
close all

cd ../
end
end

