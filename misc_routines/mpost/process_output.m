function [] = process_output(sim_names, call_loc)
%PROCESS_OUTPUT: This function is called by mpost.sh and is intended to interface a shell with
%some ED post processing scripts written in Matlab.
%  Inputs: 
%     - sim_names: Names of polygon folders found, as a string with no whitespace.
%     - call_loc : The directory this script was called from.

%----------- Inform user of minor preprocessing. ----------------------------------------------%
% Tell the user what this script sees. 
disp('process_output sees the input varaible sim_names as:')
disp(sim_names)

% Reformat the sim_names variable to be more easily used in Matlab scripts. 
sim_names = textscan(sim_names,'%s','Delimiter',',');    % Returns 1x1 cell w/ a cell in it.
sim_names = sim_names{1};                                % Extract the interior cell.

% Tell the user what this is interpreted as.
disp('Which is being interpreted as the set of polygons: ')
disp(sim_names)

% Get the number of polygons and the run lengths (start/fin times)
n_sims = length(sim_names);

%----------- Import Runs ----------------------------------------------------------------%
for sim_num = 1:n_sims
   cur_sim_name = sim_names{sim_num};
   ed2in_fname  = [cur_sim_name,'/','ED2IN'];
   namelists.(cur_sim_name) = read_namelist(ed2in_fname,'ED_NL');
   
   namelists.(cur_sim_name).f_type    = cur_sim_name;
   namelists.(cur_sim_name).start     = [ namelists.(cur_sim_name).IYEARA ,'-', ...
                                          namelists.(cur_sim_name).IMONTHA,'-', ...
                                          namelists.(cur_sim_name).IDATEA ,'-', ...
                                          namelists.(cur_sim_name).ITIMEA ,'-', ...
                                                ];
   namelists.(cur_sim_name).end       = [ namelists.(cur_sim_name).IYEARZ ,'-', ...
                                          namelists.(cur_sim_name).IMONTHZ,'-', ...
                                          namelists.(cur_sim_name).IDATEZ ,'-', ...
                                          namelists.(cur_sim_name).ITIMEZ ,'-', ...
                                                ];
   namelists.(cur_sim_name).inc       = '000000';
   namelists.(cur_sim_name).dir       = [call_loc,'/',cur_sim_name,'/analy/'];
   namelists.(cur_sim_name).splflg    = 1;

   % Check to see if the ED2IN is compatible with c13 code. If no, tell import poly.
   if isfield(namelists.(cur_sim_name),'C13AF')
      namelists.(cur_sim_name).c13out = strcmp(namelists.(cur_sim_name).C13AF,'1');
   else
      namelists.(cur_sim_name).c13out = 0;
   end

   %-------------------------------------------------------------------------------------------
   % Read all of the hdf5 output settings
   %-------------------------------------------------------------------------------------------
   simres.daily   = 0;
   simres.monthly = 0;
   simres.yearly  = 0;
   simres.fast    = 0;
   namelists.(cur_sim_name).out_types = '';
   if str2double(namelists.(cur_sim_name).IFOUTPUT) == 3
      simres.fast = 1;
      namelists.(cur_sim_name).inc = '010000';
   end
   if str2double(namelists.(cur_sim_name).IDOUTPUT) == 3
     simres.daily = 1;
   end
   %if str2double(namelists.(cur_sim_name).IMOUTPUT) == 3
   %   simres.monthly = 1;
   %end
   if str2double(namelists.(cur_sim_name).IQOUTPUT) == 3
      simres.monthly = 1;
   end
   if str2double(namelists.(cur_sim_name).IYOUTPUT) == 3
      simres.yearly = 1;
   end
   if str2double(namelists.(cur_sim_name).ITOUTPUT) == 3
      simres.tower = 1;
   end
      
   %-------------------------------------------------------------------------------------------
   % Tell the user what this script thinks the simulation looks like.
   %-------------------------------------------------------------------------------------------
   disp(' ')
   disp('==================================================================')
   disp(['Opening directory: ',namelists.(cur_sim_name).dir])
   disp('==================================================================')
   disp('Import_poly.m "believes" the following about this polygon:')   
   disp(['file type: ' namelists.(cur_sim_name).f_type           ])
   disp([' ifoutput: ' namelists.(cur_sim_name).IFOUTPUT         ])
   disp([' idoutput: ' namelists.(cur_sim_name).IDOUTPUT         ])
   disp([' imoutput: ' namelists.(cur_sim_name).IMOUTPUT         ])
   disp([' iqoutput: ' namelists.(cur_sim_name).IQOUTPUT         ])
   disp([' iyoutput: ' namelists.(cur_sim_name).IYOUTPUT         ])
   disp([' itoutput: ' namelists.(cur_sim_name).ITOUTPUT         ])
   disp(['    start: ' namelists.(cur_sim_name).start            ])
   disp(['      end: ' namelists.(cur_sim_name).end              ])
   disp(['increment: ' namelists.(cur_sim_name).inc              ])
   disp(['directory: ' namelists.(cur_sim_name).dir              ])
   disp(['split flg: ' num2str(namelists.(cur_sim_name).splflg)  ])
   disp(['      c13: ' num2str(namelists.(cur_sim_name).c13out)  ])
   disp(' ')
   

   %-------------------------------------------------------------------------------------------
   % Merge the yearly and monthly cell structures.
   %-------------------------------------------------------------------------------------------
   data.(cur_sim_name) = import_poly_multi(namelists.(cur_sim_name),simres,1);
   %-------------------------------------------------------------------------------------------
end



%----------- Save the Data to a .mat file ------------------------------------%
write_time = clock;
write_time = strcat(num2str(write_time(1)),'_',num2str(write_time(2)),'_', ... 
                    num2str(write_time(3)),'_',num2str(write_time(4)),'_', ...
                    num2str(write_time(5)));

mpost.namelists = namelists;
mpost.data      = data;
mpost.poly_nls  = namelists;

disp('==================================================================')
disp(['Saving mpost_',write_time,'.mat ...'])
save(['mpost_',write_time],'mpost')

disp(' ')
disp('mpost_interface has finished!')
end
