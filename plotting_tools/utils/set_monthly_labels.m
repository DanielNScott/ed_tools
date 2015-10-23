function [ ] = set_monthly_labels( gca, beg )
%SET_MONTHLY_LABELS(GCA,BEG) Takes the current axis and the number of the first month which has
%an x-tick and labels the axis.

   months = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
          
   xticks  = get(gca,'XTick');                % Get current x tick labels
   mxticks = cell(1,size(xticks,1));          % Save them for a moment...
   
   nticks = numel(xticks);
   
   j = 1;
   while j <= nticks                          % Cycle through x ticks
      if xticks(j) ~= round(xticks(j))        % Check if xtick is a whole number...
         xticks(j) = [];
         nticks = nticks - 1;
      else
         month_num  = mod(xticks(j)+beg-2,12)+1;   % Get the number for the month this tick should be
         mxticks{j} = months{month_num};           % Save the month in it's place
         j = j + 1;
      end
   end
   
   set(gca,'XTick',xticks)                    %
   set(gca,'XTickLabel',mxticks)              % Reset what's on the plot

end

