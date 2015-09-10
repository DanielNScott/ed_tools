function [] = test_optimizer(nopt)

acceptance   = zeros(nopt,1);
found_states = zeros(nopt,2);
for iopt = 1:nopt
   [hist, ui, cfe, ~, ~] = optimize_ed();
   found_states(iopt,:)  = hist.state(:,hist.iter_best);
   found_obj(iopt)       = hist.obj(hist.iter_best);
   acceptance(iopt)      = hist.acc_rate; 
end


if nopt == 1
   close all
   figure()
   plot_rosenbrock_2D([-3,3],[-3,3],0.1,0.1,'incs');
   hold on
   
   plot3(hist.state(1,:)  ,hist.state(2,:)  ,hist.obj(1,:)  ,'r' ,'linewidth' ,1.5);
   plot3(hist.state(1,1)  ,hist.state(2,1)  ,hist.obj(1,1)  ,'or','markers',10);
   plot3(hist.state(1,end),hist.state(2,end),hist.obj(1,end),'om','markers',10);
   
   plot3(hist.state(1,hist.iter_best),...
         hist.state(2,hist.iter_best),...
         hist.obj  (1,hist.iter_best),'og','markers',10);

   set(gcf,'Name','Test Surface and States')
   legend({'Surface','State Trajectory','First State','Last State','Best State'})
      
   hold off
   figure('Name','Two Diagnostics')
   subaxis(2,1,1, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.03)
      hold on
      plot(1:ui.niter,hist.obj)
      plot(hist.iter_best,hist.obj(hist.iter_best),'or')
      title('Objective History')
      legend({'Objectives','Best Objective'})
      hold off
   subaxis(2,1,2, 'Spacing', 0.035, 'Padding', 0.03, 'Margin', 0.035)
      hold on
      plot(1:ui.niter,hist.state)
      plot(hist.iter_best,hist.state(:,hist.iter_best),'or')
      title('Param. Chains')
      legend({'Coord 1','Coord 2','Best States'})
      hold off
      
      disp('Best State:')
      disp(hist.state(:,hist.iter_best))
      disp('Best Iter:')
      disp(hist.iter_best)
end

if nopt > 1;
   % Generate Normalized Histogram
   bin_lims = 0.1:0.1:5;
   nbins = numel(bin_lims) + 1;
   bins  = zeros(1,nbins);
   for iopt = 1:nopt
      lt_msk = found_obj(iopt) <= bin_lims;
      bin_num = find(lt_msk,1);

      if ~isempty(bin_num)
         bins(bin_num) = bins(bin_num) + 1;
      else
         bins(end) = bins(end) + 1;
      end
   end
   bins = bins/nopt*100;

   figure('Name','Optimizer Test')
   %gen_new_fig('');
   subaxis(2,2,1, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.03)
      scatter(found_states(:,1),found_states(:,2));
      title('\bf{Scatter of Best States}')
      xlabel('Coordinate 1')
      ylabel('Coordinate 2')

   subaxis(2,2,2, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.03)
      bar(found_obj)
      set(gca,'XLim',[0,nopt+1])
      title('\bf{Plot of Best Objectives}')
      xlabel('Optimization Number')
      ylabel('Objective')   

   subaxis(2,2,3, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.03)
      scatter(acceptance,found_obj)
      set(gca,'XLim',[0,1])
      title('\bf{Objective by Acceptance Fraction}')
      xlabel('Acceptance Fraction')
      ylabel('Objective')

   subaxis(2,2,4, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.03)
      bar(bins)
      set(gca,'XLim',[0,nbins+1])
      set(gca,'YLim',[0,100])
      title('\bf{Distribution Around Optimal Value}')
      xlabel('Objective Units')
      ylabel('Percent in Bin')
end
      
end