function  mp = calculateModPowerStats( mod, moments )
%
% Calculates the statistics for the modulation power
% 
% From McDermott et al.
%

mp = moments.wi * sum( mod.^2 ) / moments.m2;