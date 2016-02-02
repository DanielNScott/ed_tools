function [ ] = plot_raw_chamber_d13C( )
%plot_raw_chamber_d13C Summary of this function goes here
%   Detailed explanation goes here

fname = ['C:\Users\Dan\moorcroft_lab\observations\harvard_forest_archives' ...
         '\chamber\HF-SoilChamberDel13Results.txt'];
raw = read_cols_to_flds(fname,'\s',0,0);

chamber_exper = [1,3,5];
chamber_contr = [2,4,6];
colors  = {'b','g','r','m'};

hold on
for iplt = 1:numel(chamber_exper)
   ch_num = chamber_exper(iplt);
   ch_msk = and(raw.Ch_Num == ch_num, raw.bad_flg == 0);
   
   marker = [colors{iplt} , '.'];
   plot(raw.IgorTime_EST(ch_msk),raw.d13C(ch_msk),marker);
end
hold off


hold on
for iplt = 1:numel(chamber_contr)
   ch_num = chamber_contr(iplt);
   ch_msk = and(raw.Ch_Num == ch_num, raw.bad_flg == 0);
   
   marker = [colors{iplt} , '.'];
   plot(raw.IgorTime_EST(ch_msk),raw.d13C(ch_msk),marker);
end
hold off

end

