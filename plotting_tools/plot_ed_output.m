function [] = plot_ed_output(data)
% COMPARE_MPOST_DATA Takes as input data supplied in mpost's output format
% and outputs graphs of that data.
%----------------------------------------------------------------------
%  Input: data - the data substructure of an mpost file.
%          c13 - Graph C13; T,F = 1,0
%         type - 'many' or 'few', defines which graphs to produce.
%        years - [first year, last year] to graphclear
%
% Example: gen_many_graphs_v3(mpost.data,1,'few',[2009,20010],0)
%----------------------------------------------------------------------
years    = [];
save     = 0;
splt     = 0;
plot_c13 = 0;

%% Set up vars passed to plot utilitis
%--------- Var name --------------- Description ----------- Location --- Units ------ Fig - Splt
items = { 'MMEAN_BLEAF_CO'         'Leaf Biomass'          'T'          'kgC/m^2'      1   1;...
          'MMEAN_BSTORAGE_CO'      'Storage Biomass'       'T'          'kgC/m^2'      1   1;...
          'MMEAN_BROOT_CO'         'Root Biomass'          'T'          'kgC/m^2'      1   1;...
          'CB'                     'Carbon Balance'        'T'          'kgC/m^2'      1   1;...
          'BA_CO'                  'Total Basal Area'      'T'          'cm^2/m^2'     1   1;...
          'MMEAN_LAI_CO'           'Leaf Area Index'       'T'          'm^2l/m^2g'    1   1;...
          'MMEAN_FAST_SOIL_C'      'Mean Fast Soil C'      'T'          'kgC/m^2'      1   0;...
          'MMEAN_SLOW_SOIL_C'      'Mean Slow Soil C'      'T'          'kgC/m^2'      1   0;...
          'MMEAN_RH_PA'            'Mean Het. Resp.'       'T'          'kgC/m^2/yr'   1   0;...
          ...
          'MMEAN_LEAF_RESP_CO'     'Mean Leaf Resp'        'T'          'kgC/m^2/yr'   2   1;...
          'MMEAN_ROOT_RESP_CO'     'Mean Root Resp'        'T'          'kgC/m^2/yr'   2   1;...
          'MMEAN_VLEAF_RESP_CO'    'Mean VLeaf Resp'       'T'          'kgC/m^2/yr'   2   1;...
          'MMEAN_STORAGE_RESP_CO'  'Mean Storage Resp'     'T'          'kgC/m^2/yr'   2   1;...
          'MMEAN_GROWTH_RESP_CO'   'Mean Growth Resp'      'T'          'kgC/m^2/yr'   2   1;...
          'MMEAN_PLRESP_CO'        'Mean Plant Resp'       'T'          'kgC/m^2/yr'   2   1;...
          'MMEAN_GPP_CO'           'Mean GPP'              'T'          'kgC/m^2/yr'   2   1;...
          'MMEAN_NPP_CO'           'Mean NPP'              'T'          'kgC/m^2/yr'   2   1;...
          'MMEAN_RH_PA'            'Mean Het. Resp.'       'T'          'kgC/m^2/yr'   2   0;...
          ...
          'BA_CO'                  'Total Basal Area'      'T'          'm'            5   1;...
          'HITE'                   'Plant Heights'         'T'          'm'            5   0;...
          ...
          'Het_SResp_Frac'         'Het Soil Resp Frac'    'T'          'kgC/m^2'      6   0;...
          'Total_Bgrnd_Flux'       'Flux Below Ground'     'T'          'kgC/m^2/yr'   6   0;...
          'Frac_Bgrnd_Flux'        'Frac Blgrnd Flux'      'T'          '%'            6   0;...
         };

fignames = {'Pools', 'Fluxes', 'Some Fluxes', 'Belowground Items'};
hw_fname = {'Pools - Hw', 'Fluxes - Hw', 'Some Fluxes - Hw', 'Belowground Items - Hw'};
co_fname = {'Pools - Co', 'Fluxes - Co', 'Some Fluxes - Co', 'Belowground Items - Co'};
fnums = cell2mat(items(:,5));
   
%% Plot things. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%:
for ifig = 1:2  %range(fnums)
   %killpanel = -1;
   names = items(fnums == ifig,1);
   alias = items(fnums == ifig,2);
   prfix = items(fnums == ifig,3);
   units = items(fnums == ifig,4);
   split = items(fnums == ifig,6);
   %--------------------------------------------------------------------------------------------
   % Total Carbon, Aggregated
   %--------------------------------------------------------------------------------------------
   if splt == 0
      util_panel_plot(fignames{ifig},data,names,alias,units,prfix,years,save);
   end
   %--------------------------------------------------------------------------------------------
   % Total Carbon, PFT-Split
   %--------------------------------------------------------------------------------------------
   if splt > 0

      killpanel = [];
      for i = 1:numel(names)
         prfix{i} = 'H';
         if split{i} == 0;
            killpanel = [killpanel i];
         end
      end
      util_panel_plot(hw_fname{ifig},data,names,alias,units,prfix,years,save,killpanel);
      
      killpanel = [];
      for i = 1:numel(names)
         prfix{i} = 'C';
         if split{i} == 0;
            killpanel = [killpanel i];
         end
      end
      util_panel_plot(co_fname{ifig},data,names,alias,units,prfix,years,save,killpanel);

   end
   
   
   if plot_c13
      if ifig >= 4;
          continue;
      end
      
      fignames{ifig} = [fignames{ifig} ' delta 13C'];
      for i = 1:numel(names)
          [~, names{i}]  = get_iso_name(names{i});
          alias{i}  = [alias{i} ' \delta ^1^3C'];
          units{i}  = 'permil';
      end
      if ifig == 1 
         killpanel = 4:6;
      else
         killpanel = 0;
      end
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
