function [ ] = util_format_plot( mytitle, mylegend, interpreter, xlen, ylab, start_year, panel, npanels )
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
    
    % Format as years if more than 5 of them
    if xlen > 60
        set(gca,'XTick',[1:12:xlen+1]);
        set(gca,'XTickLabel','');
        set(gca,'XGrid','on');

        xlabel(['Years (June of)'])

        yrlist = start_year:1:(start_year+xlen/12);
        yrlist = mod(yrlist,100);
        for i=1:length(yrlist)
            if yrlist(i) < 10
                xticklabels{i} = ['0' num2str(yrlist(i))];
            else
                xticklabels{i} = num2str(yrlist(i));
            end
        end
    elseif xlen <= 60 %&& xlen > 24
    % Format in 6 month intervals if less than 5 years
        set(gca,'XTick',[1:6:xlen+1]);
        set(gca,'XTickLabel','');
        set(gca,'XGrid','on');
         
        if npanels <= 4;
           %xlabel('Dates')
        elseif npanels > 4 && panel > 4;
           %xlabel('Dates')           
        end
           
        yrlist = start_year:1:(start_year+xlen/12);
        yrlist = mod(yrlist,100);
        for i=1:length(yrlist)
            if yrlist(i) < 10
                xticklabels{2*i-1} = ['Jan 0' num2str(yrlist(i))];
                xticklabels{2*i}   = ['Jul. 0' num2str(yrlist(i))];
            else
                xticklabels{2*i-1} = ['Jan ' num2str(yrlist(i))];
                xticklabels{2*i}   = ['Jul. ' num2str(yrlist(i))];
            end
        end
%     elseif xlen > 24 && xlen < 60
%     % Format as months if <= 2 years
%         set(gca,'XTick',[1:6:xlen+1]);
%         set(gca,'XTickLabel','');
%         set(gca,'XGrid','on');
% 
%         xlabel('Dates')
% 
%         yrlist = start_year:1:(start_year+xlen/12);
%         yrlist = mod(yrlist,100);
%         for i=1:length(yrlist)
%             if yrlist(i) < 10
%                 xticklabels{2*i-1} = ['June 0' num2str(yrlist(i))];
%                 xticklabels{2*i}   = ['Dec. 0' num2str(yrlist(i))];
%             else
%                 xticklabels{2*i-1} = ['June ' num2str(yrlist(i))];
%                 xticklabels{2*i}   = ['Dec. ' num2str(yrlist(i))];
%             end
%         end    
    end
    set(gca,'XTickLabel',xticklabels);
    ylabel(ylab)
    %saveas(gcf,['.\',filesep,[pavars{i}],'.jpeg'],'jpeg');



end

