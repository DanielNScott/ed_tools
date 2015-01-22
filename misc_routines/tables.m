% Some general relationships are:
% 1W       = 1J/s
% 1ha      = 10,000 m^2
% 1tonne   = 1Mg i.e. 1,000,000 grams
% 1J       = 1/1000,000 MJ
% 1s       = SperMonth * 1/mo
%
% Substances:
% 1g H2O  '=' 2.260 J (Latent heat of vaporization)
% 1mol H20 = 18.015g H20
% 1mol CO2 = 44.01g CO2
% 1g CO2   = 0.2729g C

% These are all obvoius...
SperDay      = 60*60*24;
DperMonth    = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
SperMonth    = SperDay .* DperMonth;

% Weights and Areas
KgperT   = 1000;
SqmperHa = 10000;
KgperSqm2TperHa = 1/KgperT * SqmperHa;

% 2260 kJ is required to vaporize 1kg of water
KgWater2J = 2260 * 1000;

% Model Latent Heat is W/m^2, need to convert to MJ/m^2
W2MJperMonth = SperMonth ./ 1000000; % Array of size 1x12

% Model Sensible Heat is kg/m^2/s, need to convert to MJ/m^2
KgperS2MJperMonth = SperMonth * KgWater2J / 1000000 ; % Array of size 1x12

% 1cm = 1/100m so 1cm^2 = 1/10,000 m^2, so 1cm^2 / m^2
month_night_hrs = {...
...%0-3am  4-6am  7-9am  10-12  1-3pm  4-6pm  7-9pm  10-12  ... Month ... Daylight Hrs
   [1,1,1, 1,1,1, 0,0,0, 0,0,0, 0,0,0, 0,1,1, 1,1,1, 1,1,1];... % Jan ... 7-5
   [1,1,1, 1,1,0, 0,0,0, 0,0,0, 0,0,0, 0,0,1, 1,1,1, 1,1,1];... % Feb ... 6-6
   [1,1,1, 1,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,1, 1,1,1, 1,1,1];... % Mar ... 5-6
   [1,1,1, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 1,1,1, 1,1,1];... % Apr ... 4-7
   [1,1,1, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,1,1, 1,1,1];... % May ... 4-8
   [1,1,1, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,1,1, 1,1,1];... % Jun ... 4-8
   [1,1,1, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,1,1, 1,1,1];... % Jul ... 4-8
   [1,1,1, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 1,1,1, 1,1,1];... % Aug ... 4-7
   [1,1,1, 1,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 1,1,1, 1,1,1];... % Sep ... 5-7
   [1,1,1, 1,1,0, 0,0,0, 0,0,0, 0,0,0, 0,0,1, 1,1,1, 1,1,1];... % Oct ... 6-6
   [1,1,1, 1,1,0, 0,0,0, 0,0,0, 0,0,0, 0,1,1, 1,1,1, 1,1,1];... % Nov ... 6-5
   [1,1,1, 1,1,1, 0,0,0, 0,0,0, 0,0,0, 0,1,1, 1,1,1, 1,1,1];... % Dec ... 7-5
   };

% g/mol CO2
gpermolCO2 = 44.01;

% gC/gCO2
gCpergCO2 = 0.272892524426267;

% 13^CO_2 g/mol