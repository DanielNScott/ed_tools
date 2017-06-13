function [] = plot_general(data,resin,plot_c13,splt,save,varargin)
% COMPARE_MPOST_DATA Takes as input data supplied in mpost's output format
% and outputs graphs of that data.
%----------------------------------------------------------------------
%  Input: data - the data substructure of an mpost file.
%        resin - Resolution input, a string of ED resolution codes
%     plot_c13 - Boolean, whould d13C be plotted?
%         splt - String for which pft-type-split vars to show
%         save - Should the plots be saved to disk?
%
% Example: gen_many_graphs_v3(mpost,'DMTY',0,'THC',0)
%----------------------------------------------------------------------
years      = [];
res.fast   = any('F' == resin);
res.daily  = any('D' == resin);
res.month  = any('M' == resin);
res.yearly = any('Y' == resin);
res.tower  = any('T' == resin);

dev = 1;

%% Set up vars passed to plot utilities
items = {};
fignames = {};

% These vars exist in ed_iso only
if res.fast
   fignames{end+1} = 'Fast-Bio';
   items{end+1} = { ... FMEANS:
             'FMEAN_BLEAF_CO'             'FMean Leaf Biomass'          'T' 'kgC/m^2'         1;...
             'FMEAN_BROOT_CO'             'FMean Root Biomass'          'T' 'kgC/m^2'         1;...
             'FMEAN_BSAPWOODA_CO'         'FMean SapA Biomass'          'T' 'm^2/m^2'         1;...
             'FMEAN_BSAPWOODB_CO'         'FMean SapB Biomass'          'T' 'kgC/m^2'         1;...
             'FMEAN_LEAF_MAINTENANCE_PY'  'FMean Leaf Maintenance Loss' 'T' 'kgC/m^2'         1;...
             'FMEAN_ROOT_MAINTENANCE_PY'  'FMean Root Maintenance Loss' 'T' 'kgC/m^2'         1;...
             'FMEAN_BSTORAGE_CO'          'FMean Storage Biomass'       'T' 'kgC/m^2'         1;...
             %'FMEAN_LEAF_DROP_CO'         'FMean Leaf Drop'             'T' 'kgC/m^2'         1;...
             %'FMEAN_LAI_CO'               'FMean LAI'                   'T' 'cm^2/m^2'        1;...
             }; 
end

if res.tower || res.fast
   fignames{end+1} = 'Fast-Fluxes';
   items{end+1} = { ... FMEANS:
          'FMEAN_LEAF_RESP_PY'         'FMean Leaf Resp'        'T'      'kgC/m^2/yr'      1;...
          'FMEAN_ROOT_RESP_PY'         'FMean Root Resp'        'T'      'kgC/m^2/yr'      1;...
          'FMEAN_GPP_PY'               'FMean GPP'              'T'      'kgC/m^2/yr'      1;...
          'FMEAN_NPP_PY'               'FMean NPP'              'T'      'kgC/m^2/yr'      1;...
          };

   fignames{end+1} = 'Fast-SGR';
   items{end+1} = { ... FMEANS:
          'FMEAN_LEAF_STORAGE_RESP_PY' 'FMean Leaf Storage Resp' 'T'     'kgC/m^2/yr'      1;...
          'FMEAN_ROOT_STORAGE_RESP_PY' 'FMean Root Storage Resp' 'T'     'kgC/m^2/yr'      1;...
          'FMEAN_SAPA_STORAGE_RESP_PY' 'FMean Sapa Storage Resp' 'T'     'kgC/m^2/yr'      1;...
          'FMEAN_SAPB_STORAGE_RESP_PY' 'FMean Sapb Storage Resp' 'T'     'kgC/m^2/yr'      1;...
          'FMEAN_LEAF_GROWTH_RESP_PY'  'FMean Leaf Growth Resp'  'T'     'kgC/m^2/yr'      1;...
          'FMEAN_ROOT_GROWTH_RESP_PY'  'FMean Root Growth Resp'  'T'     'kgC/m^2/yr'      1;...
          'FMEAN_SAPA_GROWTH_RESP_PY'  'FMean Sapa Growth Resp'  'T'     'kgC/m^2/yr'      1;...
          'FMEAN_SAPB_GROWTH_RESP_PY'  'FMean Sapb Growth Resp'  'T'     'kgC/m^2/yr'      1;...
          };
end



if res.daily
   fignames{end+1} = 'Daily-Bio';
   items{end+1} = { ...
          'DMEAN_BLEAF_CO'             'DMean Leaf Biomass'          'T' 'kgC/m^2'         1;...
          'DMEAN_BROOT_CO'             'DMean Root Biomass'          'T' 'kgC/m^2'         1;...
          'DMEAN_BSAPWOODA_CO'         'DMean SapwoodA Biomass'      'T' 'm^2/m^2'         1;...
          'DMEAN_BSAPWOODB_CO'         'DMean SapwoodB Biomass'      'T' 'kgC/m^2'         1;...
          'DMEAN_LEAF_MAINTENANCE_CO'  'DMean Leaf Maintenance Loss' 'T' 'kgC/m^2'         1;...
          'DMEAN_ROOT_MAINTENANCE_CO'  'DMean Root Maintenance Loss' 'T' 'kgC/m^2'         1;...
          'DMEAN_BSTORAGE_CO'          'DMean Storage Biomass'       'T' 'kgC/m^2'         1;...
          'DMEAN_CB'                   'DMean Carbon Balance'        'T' 'kgC/m^2'         1;...
          'DMEAN_LAI_CO'               'DMean Leaf Area Index'       'T' 'cm^2/m^2'        1;...
          };
       
   fignames{end+1} = 'Daily-Fluxes';
   items{end+1} = { ...
          'DMEAN_LEAF_RESP_CO'         'DMean Leaf Resp'        'T'      'kgC/m^2/yr'      1;...
          'DMEAN_ROOT_RESP_CO'         'DMean Root Resp'        'T'      'kgC/m^2/yr'      1;...
          'DMEAN_GPP_CO'               'DMean GPP'              'T'      'kgC/m^2/yr'      1;...
          'DMEAN_NPP_CO'               'DMean NPP'              'T'      'kgC/m^2/yr'      1;...
          };
       
   fignames{end+1} = 'Daily-SGR';
   items{end+1} = { ...
          'DMEAN_LEAF_STORAGE_RESP_CO' 'DMean Leaf Storage Resp' 'T'     'kgC/m^2/yr'     1;...
          'DMEAN_ROOT_STORAGE_RESP_CO' 'DMean Root Storage Resp' 'T'     'kgC/m^2/yr'     1;...
          'DMEAN_SAPA_STORAGE_RESP_CO' 'DMean Sapa Storage Resp' 'T'     'kgC/m^2/yr'     1;...
          'DMEAN_SAPB_STORAGE_RESP_CO' 'DMean Sapb Storage Resp' 'T'     'kgC/m^2/yr'     1;...
          'DMEAN_LEAF_GROWTH_RESP_CO'  'DMean Leaf Growth Resp'  'T'     'kgC/m^2/yr'     1;...
          'DMEAN_ROOT_GROWTH_RESP_CO'  'DMean Root Growth Resp'  'T'     'kgC/m^2/yr'     1;...
          'DMEAN_SAPA_GROWTH_RESP_CO'  'DMean Sapa Growth Resp'  'T'     'kgC/m^2/yr'     1;...
          'DMEAN_SAPB_GROWTH_RESP_CO'  'DMean Sapb Growth Resp'  'T'     'kgC/m^2/yr'     1;...
          };

   fignames{end+1} = 'Daily-Soil';
   items{end+1} = { ...
          'DMEAN_FAST_SOIL_C_PY'       'DMean Fast Soil C'      'T'      'kgC/m^2'        0;...
          'DMEAN_SLOW_SOIL_C_PY'       'DMean Slow Soil C'      'T'      'kgC/m^2'        0;...
          'DMEAN_RH_PA'                'DMean Het. Resp.'       'T'      'kgC/m^2/yr'     0;...
          'DMEAN_Soil_Resp'            'DMean Soil Resp.'       'X'      'kgC/m^2/yr'     0;...
          'DMEAN_Soil_Resp_HF'         'DMean R_H / R_s_o_i_l'  'X'      'kgC/m^2/yr'     0;...
          'DMEAN_Reco'                 'DMean R_e_c_o'          'X'      'kgC/m^2/yr'     0;...
          'DMEAN_Reco_HF'              'DMean R_H / R_e_c_o'    'X'      'kgC/m^2/yr'     0;...
          'DMEAN_FAST_SOIL_N'          'DMean Fast Soil N'      'T'      ''               0;... % DNE
          'DMEAN_MINERAL_SOIL_N_PY'    'DMean Mineral Soil N'   'T'      ''               0;... % DNE
          %'DMEAN_FSN_CO'               'DMean FSN Co'           'T'      ''               0;...
          };
end

if res.month
   fignames{end+1} = 'Month-Bio';
   items{end+1} = { ...
          'MMEAN_BLEAF_CO'             'MMean Leaf Biomass'          'T'      'kgC/m^2'         1;...
          'MMEAN_BROOT_CO'             'MMean Root Biomass'          'T'      'kgC/m^2'         1;...
          'MMEAN_LAI_CO'               'MMean Leaf Area Index'       'T'      'm^2/m^2'         1;...
          'MMEAN_LEAF_MAINTENANCE_CO'  'MMean Leaf Maintenance Loss' 'T'      'kgC/m^2'         1;...
          'MMEAN_ROOT_MAINTENANCE_CO'  'MMean Root Maintenance Loss' 'T'      'kgC/m^2'         1;...
          'MMEAN_LEAF_DROP_CO'         'MMean Dropped Leaf Mass'     'T'      'kgC/m^2'         1;...
          'MMEAN_BSTORAGE_CO'          'MMean Storage Biomass'       'T'      'kgC/m^2'        1;...
          'CB'                         'MMean Carbon Balance'        'T'      'kgC/m^2'        1;...
          'BA_CO'                      'Total Basal Area'            'T'      'cm^2/m^2'       1;...
          };
       
   fignames{end+1} = 'Month-Fluxes';
   items{end+1} = { ...
          'MMEAN_LEAF_RESP_CO'         'MMean Leaf Resp'        'T'      'kgC/m^2/yr'     1;...
          'MMEAN_ROOT_RESP_CO'         'MMean Root Resp'        'T'      'kgC/m^2/yr'     1;...
          'MMEAN_GPP_CO'               'MMean GPP'              'T'      'kgC/m^2/yr'     1;...
          'MMEAN_NPP_CO'               'MMean NPP'              'T'      'kgC/m^2/yr'     1;...
          };

   fignames{end+1} = 'Month-SGR';
   items{end+1} = { ...
          'MMEAN_LEAF_STORAGE_RESP_CO' 'MMean Leaf Storage Resp' 'T'     'kgC/m^2/yr'     1;...
          'MMEAN_ROOT_STORAGE_RESP_CO' 'MMean Root Storage Resp' 'T'     'kgC/m^2/yr'     1;...
          'MMEAN_SAPA_STORAGE_RESP_CO' 'MMean Sapa Storage Resp' 'T'     'kgC/m^2/yr'     1;...
          'MMEAN_SAPB_STORAGE_RESP_CO' 'MMean Sapb Storage Resp' 'T'     'kgC/m^2/yr'     1;...
          'MMEAN_LEAF_GROWTH_RESP_CO'  'MMean Leaf Growth Resp'  'T'     'kgC/m^2/yr'     1;...
          'MMEAN_ROOT_GROWTH_RESP_CO'  'MMean Root Growth Resp'  'T'     'kgC/m^2/yr'     1;...
          'MMEAN_SAPA_GROWTH_RESP_CO'  'MMean Sapa Growth Resp'  'T'     'kgC/m^2/yr'     1;...
          'MMEAN_SAPB_GROWTH_RESP_CO'  'MMean Sapb Growth Resp'  'T'     'kgC/m^2/yr'     1;...
          };
       
   fignames{end+1} = 'Month-Soil';
   items{end+1} = { ...
          'MMEAN_FAST_SOIL_C'          'MMean Fast Soil C'      'T'      'kgC/m^2'        0;...
          'MMEAN_SLOW_SOIL_C'          'MMean Slow Soil C'      'T'      'kgC/m^2'        0;...
          'MMEAN_RH_PA'                'MMean Het. Resp.'       'T'      'kgC/m^2/yr'     0;...
          'MMEAN_Soil_Resp'            'MMean Soil Resp.'       'X'      'kgC/m^2/yr'     0;...
          'MMEAN_Soil_Resp_HF'         'MMean R_H / R_s_o_i_l'  'X'      'kgC/m^2/yr'     0;...
          'MMEAN_Reco_HF'              'MMean R_H / R_e_c_o'    'X'      'kgC/m^2/yr'     0;...
          'MMEAN_FAST_SOIL_N'          'MMean Fast Soil N'      'T'      ''               0;...
          'MMEAN_MINERAL_SOIL_N_PY'    'MMean Mineral Soil N'   'T'      ''               0;...
          'MMEAN_FSN_CO'               'MMean FSN Co'           'T'      ''               0;...
          };

   fignames{end+1} = 'Month-NPP-Alloc';
   items{end+1} = { ...
          'MMEAN_NPPDAILY_CO'          'MMean Daily NPP'            'T'  'kgC/m^2/yr'   1;...
          'MMEAN_NPPCROOT_CO'          'MMean Daily NPP to CRoots'  'T'  'kgC/m^2/yr'   1;...
          'MMEAN_NPPFROOT_CO'          'MMean Daily NPP to FRoots'  'T'  'kgC/m^2/yr'   1;...
          'MMEAN_NPPLEAF_CO'           'MMean Daily NPP to Leaves'  'T'  'kgC/m^2/yr'   1;...
          'MMEAN_NPPSAPWOOD_CO'        'MMean Daily NPP to Sapwood' 'T'  'kgC/m^2/yr'   1;...
          'MMEAN_NPPSEEDS_CO'          'MMean Daily NPP to Seeds'   'T'  'kgC/m^2/yr'   1;...
          'MMEAN_NPPWOOD_CO'           'MMean Daily NPP to Wood'    'T'  'kgC/m^2/yr'   1;...
          'MMEAN_NEP_PY'               'MMean NEP'                  'T'  'kgC/m^2/yr'   1;...
          'MMEAN_NPP_CO'               'MMean NPP'                  'T'  'kgC/m^2/yr'   1;...
          };
end

if res.yearly
   fignames{end+1} = 'Yearly-Bio';
   items{end+1} = { ... FMEANS:
          'BAG'                        'YMean Basal Area Growth'   'T'  'm^2/ha/yr'    1;...
          'BAM'                        'YMean Basal Area Mort  '   'T'  'm^2/ha/yr'    1;...
   };
end
...          'FMEAN_CARBON_ST_PA'         'Mean Carbon Storage'    'T'     'kgC/m^2/yr'   8   0;...
...          'FMEAN_CARBON_AC_PA'         'Mean Atm to CAS C Flux' 'T'     'kgC/m^2/yr'   8   0;...
...          'FMEAN_CSTAR_PA'             'Mean C*'                'T'     'kgC/m^2/yr'   8   0;...
...          'HITE'                       'Plant Heights'          'T'      'm'           8   0;...

hw_fname = strcat(fignames,'-Hw');
co_fname = strcat(fignames,'-Co');
min_figs = length(items);

% Plot things
for ifig = 1:min_figs
   names = items{ifig}(:,1);
   alias = items{ifig}(:,2);
   prfix = items{ifig}(:,3);
   units = items{ifig}(:,4);
   split = items{ifig}(:,5);
   
   %--------------------------------------------------------------------------------------------
   % Total Carbon, Aggregated
   %--------------------------------------------------------------------------------------------
   if any(splt == 'T');
      util_panel_plot(fignames{ifig},data,names,alias,units,prfix,years,save);
   end
   
   %--------------------------------------------------------------------------------------------
   % Total Carbon, PFT-Split
   %--------------------------------------------------------------------------------------------
   if ~isempty(splt)
      if any(sum(cell2mat(split)) == 0); continue; end
      
      % Hardwoods
      if any(splt == 'H')
         killpanel = [];
         for i = 1:numel(names)
            prfix{i} = 'H';
            if split{i} == 0;
               killpanel = [killpanel i];
            end
         end
         util_panel_plot(hw_fname{ifig},data,names,alias,units,prfix,years,save,killpanel);
      end

      % Conifers
      if any(splt == 'C')
         killpanel = [];
         for i = 1:numel(names)
            prfix{i} = 'C';
            if split{i} == 0;
               killpanel = [killpanel i];
            end
         end
         util_panel_plot(co_fname{ifig},data,names,alias,units,prfix,years,save,killpanel);
      end

   end
   
   if plot_c13
      fignames{ifig} = [fignames{ifig} ' delta 13C'];
      for i = 1:numel(names)
          [~, names{i}]  = get_iso_name(names{i});
          alias{i}  = [alias{i} ' \delta ^1^3C'];
          units{i}  = 'permil';
      end

      killpanel = 0;
      util_panel_plot(fignames{ifig}, ...
                data,...
                names,...
                alias,...
                units,...
                prfix,...
                years,...
                save,...
                killpanel);
   end
end

end








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
polyNamesIn = fieldnames(data);

if isfield(data,'write_time')
   index = find(strcmp('write_time',polyNamesIn));
   polyNamesIn = remove_cell_entry(polyNamesIn',index)';
end

[start_year, start_month, ~,~,~,~] = ...
   tokenize_time(data.(polyNamesIn{1}).sim_beg,'ED','num');
npanels     = numel(vars);
npolys      = numel(polyNamesIn);
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
set(fig,'Position',[1, 31, 1257, 769]);
hold on
%----------------------------------------------------------------------



%----------------------------------------------------------------------
% The plotting loop follows
%----------------------------------------------------------------------
num_nonex_total = 0;
for i=1:npanels
   
   % Figure out what panels to create and create + format them
   if any(killpanel == i); continue; end;
   if any(npanels == [7,8,9])
      subaxis(3,3,i, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.03)
      
   elseif any(npanels == [5,6])
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
   num_nonex_pvars = 0;
   polyNames = polyNamesIn;
   
   for pnum = 1:npolys
      cur_poly = polyNamesIn{pnum};
      cur_prfx = prefix{i};
      cur_varn = vars{i};
      
      var_present = isfield(data.(cur_poly).(cur_prfx),cur_varn);
      if var_present
         cur_var = data.(cur_poly).(cur_prfx).(cur_varn);
         
         last_yval_ind = pnum - 1 - num_nonex_pvars;
         if pnum > 1 && ~isempty(yvals) && length(cur_var) > length(yvals(last_yval_ind,:))
            disp(['Field truncated: ',cur_poly,'.',cur_prfx,'.',cur_var])
            yvals(pnum,:) = cur_var(1:length(yvals(pnum-1,:)));
            
         elseif isempty(cur_var)
            disp(['Skipping non-existent field: ',cur_poly,'.',cur_prfx,'.',cur_varn])
            polyNames = remove_cell_entry(polyNames',pnum - num_nonex_pvars)';
            num_nonex_pvars = num_nonex_pvars + 1;
  
         else
            yvals(pnum,:) = data.(cur_poly).(cur_prfx).(cur_varn);
            
         end
      else
         disp(['Skipping non-existent field: ',cur_poly,'.',cur_prfx,'.',cur_varn])
         polyNames = remove_cell_entry(polyNames',pnum - num_nonex_pvars)';
         num_nonex_pvars = num_nonex_pvars + 1;
      end
   end
   num_nonex_total = num_nonex_total + num_nonex_pvars;
   if num_nonex_pvars == npolys; continue; end
      
   % What years do we want from the above data? Crop out those
   % points...
   if numel(years) > 0;
      num_data = (years(2) - years(1)) * 12;
      ind1     = (years(1) - start_year)*12 + 1;
      ind2     = ind1 + num_data - 1;
      yvals    = yvals(:,ind1:ind2);
   end
   
   switch aliases{i}(1:2)
      case('FM')
         res = 'hourly';
      case('DM')
         res = 'daily';
      case('MM')
         res = 'monthly';
      case('YM')
         res = 'yearly';
      otherwise
         res = 'monthly';
   end
   
   % Format Plots
   datalength = length(yvals);
   
   if strcmp(res,'yearly')
      bar(yvals')
   else
      plot(1:datalength,yvals)
   end
   if numel(years) > 0
      util_format_plot(aliases{i}, polyNames, 2, datalength,units{i}, years(1), 1, i, npanels, res)
   else
      util_format_plot(aliases{i}, polyNames, 2, datalength,units{i}, start_year, start_month, i, npanels, res)
   end
   
end
   %----------------------------------------------------------------------
   
   
if num_nonex_total == npanels*npolys;
   disp('No information plotted in current figure. Closing it.')
   close(gcf);
   return
end
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



