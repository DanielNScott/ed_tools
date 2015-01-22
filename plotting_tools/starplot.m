function [] = starplot(data,labels,figname,save)

for i = 1:size(data,2)
   std_data(:,i) = data(:,i)/max(data(:,i)); 
end

mFigure = figure();
set(gcf, 'Color', 'white');
hold on
%glyphplot(std_data(1,:),'standardize','off','color','r','ObsLabels','')
%glyphplot(std_data(2,:),'standardize','off','color','b','ObsLabels','','varLabels',labels)
hold off

set(gca,'Position',[0.11,0.11,0.775,0.775])
set(gca,'OuterPosition',[0,0,1,1])

set(gca,'xlim',[0.3,1.7])
set(gca,'ylim',[0.3,1.7])
set(gca,'xcolor',get(gcf,'color'))
set(gca,'ycolor',get(gcf,'color'))
set(gca,'xtick',[])
set(gca,'ytick',[])
title(['\bf ' figname])

num_axes = numel(labels);
ndsets   = size(std_data,1);
valpos{num_axes,ndsets} = [];

for i = 1:num_axes
   thetadeg = i*360/num_axes;
   theta    = i*2*pi/num_axes;
   unscXY   = [cos(theta),sin(theta)];
   center   = [1, 1];
   txtloc   = unscXY*0.53;
   position = center + txtloc;
   vertex   = center + unscXY*0.4;
   
   % Create value positions cell array
   % valpos =  [dataset 1 coord, p1]   [dataset 2 coord, p1]
   %           [dataset 1 coord. p2]   [dataset 2 coord, p2]
   %           etc...
   for idset = 1:ndsets
      valpos{i,idset}   = [valpos{i,idset}, center + unscXY * std_data(idset,i) * 0.4 ];
   end
      
   % Draw datasets
   if i >= 2
      for idset = 1:ndsets
         dline_xs = [valpos{i-1,idset}(1), valpos{i,idset}(1)];
         dline_ys = [valpos{i-1,idset}(2), valpos{i,idset}(2)];
         colors = [0,0,1]*(idset == 1)+ [1,0,0]*(idset == 2);
         line(dline_xs, dline_ys, 'color', colors)
      end
      
      % Connect final to initial of each dataset
      if i == num_axes
         for idset = 1:ndsets
            dline_xs = [valpos{i,idset}(1), valpos{1,idset}(1)];
            dline_ys = [valpos{i,idset}(2), valpos{1,idset}(2)];
            colors = [0,0,1]*(idset == 1)+ [1,0,0]*(idset == 2);
            dhand{idset} = line(dline_xs, dline_ys, 'color', colors);      
         end
      end
   end
   
   % Modify label to include list of vals.
   ival = num2str(data(1,i),'%10.3f');
   bval = num2str(data(2,i),'%10.3f');
   labels{i} = {['\bf{' labels{i} '}'],['\rm{' 'Init   : ' ival '}'],['Best: ' bval]};
   
   % Insert Labels
   mText = text(position(1),position(2),labels{i},'FontSize',8);
   mTextExt = get(mText,'Extent');
   newpos = [position(1)- mTextExt(3)/2, position(2)];
   set(mText,'Position',newpos)
   
   % Draw Spokes as thicker black lines
   spoke_xs = [1,vertex(1)];
   spoke_ys = [1,vertex(2)];
   line(spoke_xs,spoke_ys,'color',[0,0,0],'LineWidth',2)
   
end

% Insert a legend with each dataset.
dset_names = {'Initial', 'Best'};
legend([dhand{:}],dset_names);
%xlabel('Conifer Parameters','Color',[0,0,0])

if save;
    export_fig(gcf, figname, '-jpg', '-r150' );
end

end