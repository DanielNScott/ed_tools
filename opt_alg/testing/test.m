function [] = test()


[state_hist, obj_val_hist, best_iter] = optimize_ed('settings_test');

len = length(obj_val_hist);

close all;

figure('Name','Objective Value History')
plot(1:len,obj_val_hist)

figure('Name','State History')
plot(1:len,state_hist)
legend('Param 1','Param 2')

disp('Best Iter: ')
disp(best_iter)
disp('Best State: ')
disp(state_hist(:,best_iter))