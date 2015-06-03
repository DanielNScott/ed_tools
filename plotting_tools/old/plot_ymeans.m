function [ ymeans ] = plot_ymeans( data )
%GET_YMEANS Summary of this function goes here
%   Detailed explanation goes here

close all;

polys  = fieldnames(data);
npolys = numel(polys);

for ipoly = 1:npolys
   poly_name = polys{ipoly};
   
   gpp = data.(poly_name).T.MMEAN_GPP_CO(8:end);
   npp = data.(poly_name).T.MMEAN_NPP_CO(8:end);
   nep = data.(poly_name).T.MMEAN_NEP_PY(8:end);
   
   ra  = data.(poly_name).T.MMEAN_PLRESP_CO(8:end);
   rh  = data.(poly_name).T.MMEAN_RH_PY(8:end);
   re  = ra + rh;
   rs  = rh - data.(poly_name).T.MMEAN_CWD_RH_PY(8:end) ...
            + data.(poly_name).T.MMEAN_ROOT_RESP_CO(8:end);
   
   lit = data.(poly_name).T.MMEAN_LEAF_DROP_CO(8:end) ...
       + data.(poly_name).T.MMEAN_LEAF_MAINTENANCE_CO(8:end) ...
       + data.(poly_name).T.MMEAN_NPPSEEDS_CO(8:end);
    
   fol = data.(poly_name).T.MMEAN_BLEAF_CO(8:end);
   fr  = data.(poly_name).T.MMEAN_BROOT_CO(8:end);
   
   wd  = data.(poly_name).T.MMEAN_NPPWOOD_CO(8:end);
   
   nyrs = length(gpp)/12;
   
   fracs = yrfrac(1:12,2001:2012);
   prepad = NaN(8,1);
   
   ymeans.(poly_name).gpp = [prepad; sum(reshape(gpp,nyrs,12)' .* fracs,2)];
   ymeans.(poly_name).npp = [prepad; sum(reshape(npp,nyrs,12)' .* fracs,2)];
   ymeans.(poly_name).nep = [prepad; sum(reshape(nep,nyrs,12)' .* fracs,2)];

   ymeans.(poly_name).ra = [prepad; sum(reshape(ra,nyrs,12)' .* fracs,2)];
   ymeans.(poly_name).rh = [prepad; sum(reshape(rh,nyrs,12)' .* fracs,2)];
   ymeans.(poly_name).re = [prepad; sum(reshape(re,nyrs,12)' .* fracs,2)];
   ymeans.(poly_name).rs = [prepad; sum(reshape(rs,nyrs,12)' .* fracs,2)];

   ymeans.(poly_name).lit = [prepad; sum(reshape(lit,nyrs,12)' .* fracs,2)];
   ymeans.(poly_name).fol = [prepad; sum(reshape(fol,nyrs,12)' .* fracs,2)];
   ymeans.(poly_name).fr  = [prepad; sum(reshape(fr,nyrs,12)'  .* fracs,2)];
   ymeans.(poly_name).wd  = [prepad; sum(reshape(wd,nyrs,12)'  .* fracs,2)];
end

raw_gee = readtext('C:\Users\Dan\Moorcroft_Lab\data\USHa2_ROSES\HF_EMS_GEE_Monthly.dat','\s');
ymeans.bill.gpp = -10*sum(cell2mat(raw_gee(3:end,2:end)),2);

raw_nee = readtext('C:\Users\Dan\Moorcroft_Lab\data\USHa2_ROSES\HF_EMS_NEE_Monthly.dat','\s');
ymeans.bill.nee = 10*sum(cell2mat(raw_nee(3:end,2:end)),2);

raw_re = readtext('C:\Users\Dan\Moorcroft_Lab\data\USHa2_ROSES\HF_EMS_RECO_Monthly.dat','\s');
ymeans.bill.re = 10*sum(cell2mat(raw_re(3:end,2:end)),2);

%gpp_check_def = -(ymeans.hf_caf0_def.gpp*10 - ymeans.hf_caf0_def.re*10);
%gpp_check_np2 = -(ymeans.hf_caf0_np2.gpp*10 - ymeans.hf_caf0_np2.re*10);

figure();
hold on
plot(1992:2011,ymeans.hf_caf0_np2.nep'*10,'-or')
plot(1992:2011,ymeans.hf_caf0_np2.wd' *10,'-^b')
plot(1992:2011,ymeans.hf_caf0_np2.lit'*10,'-+g')
legend({'NEE','Wood Increment','Litter'})
ylabel('MgC/ha/year')
xlabel('Year')
hold off

% figure();
% subaxis(3,2,1, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.05)
%    plot(1992:2011,[ymeans.bill.nee, ymeans.hf_caf0_def.nep*-10, ymeans.hf_caf0_np2.nep*-10]')
%    title('NEE')
% 
% subaxis(3,2,3, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.05)
%    plot(1992:2011,[ymeans.bill.gpp, ymeans.hf_caf0_def.gpp*10, ymeans.hf_caf0_np2.gpp*10]')
%    title('GPP')
% 
% subaxis(3,2,5, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.05)
%    plot(1992:2011,[ymeans.bill.re, ymeans.hf_caf0_def.re*10, ymeans.hf_caf0_np2.re*10]')
%    title('Reco')
%    
%    
% subaxis(3,2,2, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.05)
%    plot(1992:2011,[ymeans.hf_caf0_def.lit*10, ymeans.hf_caf0_np2.lit*10]')
%    title('Litter')
% 
% subaxis(3,2,4, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.05)
%   plot(1992:2011,[ymeans.hf_caf0_def.wd*10, ymeans.hf_caf0_np2.wd*10]')
%   title('NPP Wood')

%subaxis(3,2,6, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.05)
%   plot(1992:2011,[ymeans.bill.re, ymeans.hf_caf0_def.re*10, ymeans.hf_caf0_np2.re*10]')
%   title('Reco')


end

