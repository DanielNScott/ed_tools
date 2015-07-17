function [ beg, fin ] = get_sim_times( namelist )
%GET_SIM_TIMES Returns Simulation beginning and end strings from an ED2IN namelist.

beg = [namelist.IYEARA ,'-',namelist.IMONTHA,'-',namelist.IDATEA ,'-',namelist.ITIMEA];
fin = [namelist.IYEARZ ,'-',namelist.IMONTHZ,'-',namelist.IDATEZ ,'-',namelist.ITIMEZ];


end

