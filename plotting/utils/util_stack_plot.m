function [] = util_stack_plot(fig_name,data,vars,aliases,units,prefix,years,save,varargin)
%MY_PLOT Plots inputs in ways I often wish to replicate.
%   Detailed explanation goes here
    %----------------------------------------------------------------------
    % INPUTS:
    % fig_name:     Name of figure to be created
    % vars:         Names of vars as found in mpost structure
    % aliases:      Names to be put on graphs
    % units:        Units of each variable, to be put on graphs
    % prefix:       Path in mpost structure from polyNames and var
    % years:        [first year to graph , last year to graph]
    % save:         Boolean, save the figure?
    %----------------------------------------------------------------------
    
    %----------------------------------------------------------------------
    % polyNames:    Names of polygons as found in mpost structure
    % start_year:   First year of dataset
    % npolys:       Number of polygons to graph on each panel
    % npanels:      Number of panels in the figure window    
    %----------------------------------------------------------------------
    polyNames  = fieldnames(data);
    start_year = str2double( data.(polyNames{1}).sim_beg(end-3:end));
    nvars  = numel(vars);
    npolys = numel(polyNames);   
    %----------------------------------------------------------------------
    
    
    
    %----------------------------------------------------------------------
    % Some plotting prep.
    %----------------------------------------------------------------------
    figure('name',fig_name);
    % Standardized screen size...
    % set(fig,'Position',[1 1 1280 1024]);
    hold on
    %----------------------------------------------------------------------

    

    %----------------------------------------------------------------------
    % The plotting loop follows
    %----------------------------------------------------------------------
    plotdata = [];
    for i=1:nvars
        % Figure out the data that will be graphed
        yvals = [];
        for j=1:npolys
            if strcmp(prefix{i},'de.pa.T')
                yvals(j,:) = data.(polyNames{j}).de.pa.T.(vars{i});
            elseif strcmp(prefix{i},'de.si')
                yvals(j,:) = data.(polyNames{j}).de.si.(vars{i});
            elseif strcmp(prefix{i},'de.yrsum')
                yvals(j,:) = data.(polyNames{j}).de.yrsum.(vars{i});
           elseif strcmp(prefix{i},'ed')
                yvals(j,:) = cell2mat(data.(polyNames{j}).ed.(vars{i}));
            end
        end
        
        % What years do we want from the above data? Crop out those
        % points...
        if numel(years) > 0;
            num_data = (years(2) - years(1)) * 12;
            ind1     = (years(1) - start_year)*12 + 1;
            ind2     = ind1 + num_data - 1;
            yvals    = yvals(:,ind1:ind2);
        end
        plotdata(i,:) = yvals;
    end
        
    % Plot the data figured out above
    datalength = length(plotdata);
    % Format Plots
    if strcmp(prefix{i},'de.yrsum')
%        plot(1:datalength,NRG.data(2:end,4),'m')
        plot([12:12:length(data)*12],plotdata)
        util_format_plot(fig_name, aliases, 1, length(12:12:length(plotdata)*12),units{i}, years(1)) 
    else
        plot(1:datalength,plotdata)
        util_format_plot(fig_name, aliases, 1, datalength, units{i}, years(1)) 
    end
    %----------------------------------------------------------------------

    
    
    %----------------------------------------------------------------------
    % Maybe save the figure...
    %----------------------------------------------------------------------
    set(gcf, 'Color', 'white');     % white bckgr
    if save == 1
        export_fig( gcf, ...        % figure handle
                    fig_name,...    % name of output file without extension
                    '-painters', ...% renderer
                    '-jpg', ...     % file format
                    '-r150' );      % resolution in dpi
    end
    %----------------------------------------------------------------------    
end


