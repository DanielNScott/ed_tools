function [ ind ] = get_date_index( dstr1, dstr2, res )
%GET_DATE_INDEX(DSTR1,DSTR2,RES) returns the index DSTR2 would have in a matrix of times with
%resolution RES, were such a matrix to start with DSTR1, i.e. if the matrix had the form
%[DSTR1, DSTR1 + increment, DSTR1 + 2*increment ... DSTR2]. If DSTR2 predates DSTR1, we return
%the signed number of elements ahead of DSTR1 DSTR2 is, see ex. 2 below.
%    EX1 get_date_index('2012-01-01-01-00-00','2012-01-03-02-00-00','hourly') should return the
%    index of the latter date string from the matrix:
%        ['2012-01-01-01-00-00', '2012-01-01-02-00-00' ... '2012-01-03-02-00-00']
%    which is to say it should return 24+24+1 = 49.
%
%    EX2 get_date_index('2012-01-01-01-00-00','2013-01-03-02-00-00','yearly') returns -1.


order = order_times(dstr1,dstr2,res);

if order == 0;                                        % Then dstr2 is the same date as dstr1
  ind = 1;                                            % ... and it's the first an ra of dates
  return;
elseif order < 0;
   tmp = dstr2;
   dstr2 = dstr1;
   dstr1 = tmp;
end

[yr1,mo1,d1,hr1,~,~] = tokenize_time(dstr1,'std','num');
[yr2,mo2,d2,hr2,~,~] = tokenize_time(dstr2,'std','num');

yr_diff = yr2 - yr1;
mo_diff = mo2 - mo1;
d_diff  = d2  - d1 ;
hr_diff = hr2 - hr1;

if strcmp(res,'yearly')
   ind = yr_diff + 1;

elseif strcmp(res,'monthly')
   ind = yr_diff*12 + mo_diff + 1;

elseif any(strcmp(res,{'daily','hourly'}))
   nday_mat = yrfrac(1:12,yr1:yr2,'-days')';
   nyrs     = yr_diff + 1;
   nday_seq = reshape(nday_mat, nyrs*12, 1);
    
   mo1_ind = mo1;
   mo2_ind = length(nday_seq) - (12-mo2) -1;
   
   rel_nday_seq = nday_seq(mo1_ind:mo2_ind);
   nd_in_rel_mo = sum(rel_nday_seq);
   
   ind = nd_in_rel_mo + d_diff + 1;
   
   if strcmp(res,'hourly')
      ind = (ind-1) * 24 + hr_diff + 1;
   end
end

if order == -1
   ind = -ind + 1;
end
   
end

