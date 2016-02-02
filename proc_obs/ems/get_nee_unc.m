function [ unc ] = get_nee_unc( data )
%GET_NEE_UNC Computes Hollinger & Richardson 2005 total uncertainty in umolCO2/m2/s

data(data == -9999) = NaN;
msk_nans = isnan(data);

unc  = (data <  0).*(-0.35/3*data + 1.75) + ... 
       (data >= 0).*(0.325  *data + 1.75);

unc(msk_nans) = NaN;

end

