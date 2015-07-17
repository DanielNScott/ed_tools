function [ data ] = convert_units( data)
%CONVERT_UNITS Takes a matrix and applies a conversion factor.
%   Detailed explanation goes here

fact_1 =  1/10^6 * 44.0095 * 0.272892;   % gC/m2/s   = umolCO2/m2/s *(mol/umol *g/mol *gC/gCO2)
fact_2 = 60*60*24*365.24 * 1/1000;       % kgC/m2/yr = gC/m2/s * (s/yr * kg/g)

data = data *fact_1 *fact_2;

end

