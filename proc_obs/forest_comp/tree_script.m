
% This script produces a meaningful/usable 'trees' datastructure.

trees = read_treedata();
trees = process_treedata(trees);

gen_new_fig('HF_BA_by_Year');

hw_frac = trees.BA(2,:)./trees.BA(1,:);
hw_frac_ave = num2str(mean(hw_frac));
hw_frac_std = num2str(std(hw_frac));

hold on
plot(1998:2013,trees.BA(1,:),'--or')
plot(1998:2013,trees.BA(2,:),'--^b')
plot(1998:2013,trees.BA(3,:),'--sg');
hold off

text = {['Mean Hardwood Fraction of BA: ' hw_frac_ave],['Std Dev: ', hw_frac_std]};
annotation('textbox', [0.2,0.4,0.1,0.1],...
           'String', text);

title('Basal Area by Year in Harvard Forest EMS Plots')
ylabel('Basal Area [m^2/ha]')
xlabel('Year')
legend({'Total BA', 'Hardwood BA', 'Conifer BA'})


