function [ ] = set_monthly_labels( gca, beg )
%SET_MONTHLY_LABELS Summary of this function goes here
%   Detailed explanation goes here

   months = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
          
   xticks  = get(gca,'XTick');                % Get current x tick labels
   mxticks = cell(1,size(xticks,1));          % Save them for a moment...
   
   for j = 1:numel(xticks)                    % Cycle through x ticks
    month_num  = mod(xticks(j)+beg-2,12)+1;   % Get the number for the month this tick should be
    mxticks{j} = months{month_num};           % Save the month in it's place
   end
   
   set(gca,'XTickLabel',mxticks)              % Reset what's on the plot

end

