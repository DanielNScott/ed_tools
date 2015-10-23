function [ ] = util_format_plot(mytitle, mylegend, interpreter, xlen, ylab, start_year, ...
                                 start_month, panel, npanels, res )
%FORMAT_PLOT Summary of this function goes here
%   Detailed explanation goes here

    if interpreter == 0
        title(mytitle,'Interpreter','None','')
        legend(mylegend,'Interpreter','None','Location','NorthWest')
        
    elseif interpreter == 1
        title(mytitle)
        legend(mylegend,'Location','NorthWest')
        
    elseif interpreter == 2
        title(mytitle,'FontWeight','Bold')
        legend(mylegend,'Interpreter','None','Location','NorthWest')
        
    end
    
    set(gca,'XLim',[1,xlen]);    
    switch res
       case('yearly')
          set(gca,'XTick',[1:12:xlen+1]);
          set(gca,'XTickLabel','');
          
          if npanels == 9
             if any(panel == [7,8,9])
                xlabel('Years (June of)')
             end
          end
          
          yrlist = start_year:1:(start_year+xlen/12);
          yrlist = mod(yrlist,100);
          
          for i=1:length(yrlist)
             if yrlist(i) < 10
                xticklabels{i} = ['0' num2str(yrlist(i))];
             else
                xticklabels{i} = num2str(yrlist(i));
             end
          end
          
          set(gca,'XTickLabel',xticklabels);
       
       case('monthly')
          child = get(gca,'Children');
          set(child,'LineStyle','--');
          set(child,'Marker','o');
          set_monthly_labels(gca,start_month)
          
       case({'hourly','daily'})
          child = get(gca,'Children');
          set(child,'LineStyle','none');
          set(child,'Marker','.');
          
    end
    set(gca,'XGrid','on');
    set(gca,'YGrid','on');

    ylabel(ylab)
    %saveas(gcf,['.\',filesep,[pavars{i}],'.jpeg'],'jpeg');

end

