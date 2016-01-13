function [ ] = compare_fmean_nep( mpost, sim1, sim2, tower)
%NI Summary of this function goes here
%   Detailed explanation goes here

sim1_nep = mpost.(sim1).T.FMEAN_NEP_PY;
sim2nep = mpost.(sim2).T.FMEAN_NEP_PY;

dlen = length(sim1_nep);

figure()

subaxis(3,3,1)
hold on
plot(1:dlen,sim1_nep,'.r')
plot(1:dlen,sim2nep,'.g')
hold off
legend('sim1','sim2')

subaxis(3,3,4)
plot(sim1_nep,sim2nep,'.')
Rsq = double(1 - sum((sim1_nep - sim2nep).^2)/sum((sim1_nep - mean(sim1_nep)).^2));
disp(['R^2: ', num2str(Rsq)])

subaxis(3,3,7)
plot(1:dlen,sim1_nep - sim2nep,'.')

if tower
   years = 2011;
else
   years = [2010,2011];
end

[nt_op, dt_op] = get_nt_dt_ops(years);

if ~tower
   shift_ind = sum(yrfrac(1:5,2010,'-days')) * 24 + 1;
   nt_op = nt_op(shift_ind:(shift_ind+dlen-1));
   dt_op = dt_op(shift_ind:(shift_ind+dlen-1));
end


sim1_nep_dt = sim1_nep .* dt_op';
sim2nep_dt = sim2nep .* dt_op';

subaxis(3,3,2)
hold on
plot(1:dlen,sim1_nep_dt,'.r')
plot(1:dlen,sim2nep_dt,'.g')
hold off
legend('sim1','sim2')

subaxis(3,3,5)
plot(sim1_nep_dt,sim2nep_dt,'.')
Rsq_dt = 1 - nansum((sim1_nep - sim2nep).^2)/nansum((sim1_nep_dt - nanmean(sim1_nep_dt)).^2);
disp(['Daytime R^2: ', num2str(Rsq_dt)])

subaxis(3,3,8)
plot(1:dlen,sim1_nep_dt - sim2nep_dt,'.')


sim1_nep_nt = sim1_nep .* nt_op';
sim2nep_nt = sim2nep .* nt_op';

subaxis(3,3,3)
hold on
plot(1:dlen,sim1_nep_nt,'.r')
plot(1:dlen,sim2nep_nt,'.g')
hold off
legend('sim1','sim2')

subaxis(3,3,6)
plot(sim1_nep_nt,sim2nep_nt,'.')
Rsq_nt = 1 - nansum((sim1_nep - sim2nep).^2)/nansum((sim1_nep_nt - nanmean(sim1_nep_nt)).^2);
disp(['Night Time R^2: ', num2str(Rsq_nt)])

subaxis(3,3,9)
plot(1:dlen,sim1_nep_nt - sim2nep_nt,'.')

end

