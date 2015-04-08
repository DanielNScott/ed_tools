function [] = util_panel_plot(fig_name,data,vars,aliases,units,prefix,years,save,varargin)
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
    polyNames   = fieldnames(data);
    [start_year, start_month, ~,~,~,~] = ...
         tokenize_time(data.(polyNames{1}).nl.start,'ED','num');
    npanels     = numel(vars);
    npolys      = numel(polyNames);
    %----------------------------------------------------------------------
    
    
    
    %----------------------------------------------------------------------
    % Some plotting prep.
    %----------------------------------------------------------------------
    if nargin == 9;
        killpanel = varargin{1};
    else
        killpanel = 0;
    end

    fig = figure('name',fig_name);
    % Standardized screen size...
    set(fig,'Position',[1 1 1280 1024]);
    hold on
    %----------------------------------------------------------------------

    

    %----------------------------------------------------------------------
    % The plotting loop follows
    %----------------------------------------------------------------------
    for i=1:npanels
        
        % Figure out what panels to create and create + format them
        if any(killpanel == i); continue; end;
        if npanels == 9
            subaxis(3,3,i, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.03)           
        elseif npanels == 6 || npanels == 5
            subaxis(3,2,i, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
        elseif npanels == 4
            subaxis(2,2,i, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
        elseif npanels == 3
            subaxis(3,1,i, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
        elseif npanels == 2
            subaxis(2,1,i, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
        end
     
        % Figure out the data that will be graphed
        yvals = [];
        for j=1:npolys
            if strcmp(prefix{i},'T')
                yvals(j,:) = data.(polyNames{j}).T.(vars{i});
            elseif strcmp(prefix{i},'H')
                yvals(j,:) = data.(polyNames{j}).H.(vars{i});
            elseif strcmp(prefix{i},'C')
                yvals(j,:) = data.(polyNames{j}).C.(vars{i});
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

        % Format Plots
        datalength = length(yvals);
        if strcmp(prefix{i},'de.yrsum')
%             plot(1:datalength,NRG.data(2:end,4),'m')
            plot([12:12:length(yvals)*12],yvals)
            if numel(years)>0
                util_format_plot(aliases{i}, polyNames, 2, length(12:12:length(yvals)*12),units{i}, years(1), 1, i, npanels)
            else
                util_format_plot(aliases{i}, polyNames, 2, length(12:12:length(yvals)*12),units{i}, start_year, start_month, i, npanels)
            end
        else
            plot(1:datalength,yvals)
            if numel(years) > 0
                util_format_plot(aliases{i}, polyNames, 2, datalength,units{i}, years(1), 1, i, npanels)
            else
                util_format_plot(aliases{i}, polyNames, 2, datalength,units{i}, start_year, start_month, i, npanels)
            end
        end
    end
    %----------------------------------------------------------------------

    
    
    %----------------------------------------------------------------------
    % Maybe save the figure...
    %----------------------------------------------------------------------
    set(gcf, 'Color', 'white');     % white bckgr
    if save == 1
        export_fig( gcf, ...        % figure handle
                    fig_name,...    % name of output file without extension
                    '-jpg', ...     % file format
                    '-r150' );      % resolution in dpi
    end
    %----------------------------------------------------------------------    
end

