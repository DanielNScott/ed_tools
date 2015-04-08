function [ ] = pieplot( data, labels )
%PIEPLOT Summary of this function goes here
%   Detailed explanation goes here

   [data, permutation] = sort(data,'descend');
   labels = labels(permutation);

   % Remove anything non-positive and tell the user:
   non_pos = data <= 0;
   
   nnon_pos = sum(non_pos);
   if nnon_pos > 0;
      disp('PiePlot: Removed Non-Positive Data!');
      non_pos_data = data(non_pos);
      non_pos_lbls = labels(non_pos);
      for i = 1:nnon_pos
         disp([non_pos_lbls(i), num2str(non_pos_data(i))])
      end
   end
      
   labels = labels(~non_pos);
   data   = data(~non_pos);
   
   % Agglomerate everything less than 1%
   dsum  = sum(data);
   dmask = data./dsum > 0.01;
   
   % Figure out which names to use in legend and finalize get 'better' and 'worse' matrices.
   if numel(data(~dmask)) > 0;
      marg   = sum(data(~dmask));
      labels = [labels(dmask), {'Others, < 1% Each'}];
   else
      marg   = [];
      labels = labels(dmask);
   end
   data = [data(dmask), marg];
   
   % Actually plot things:
   pie(data); colormap(cool);
   legend(labels,'Interpreter','None','Location','SouthEast')
   
end

