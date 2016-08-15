function  grad = calculateModPowerGrads( mod, mod2, moments )
%
% Calculates the gradients for the modulation power
% 
% From McDermott et al.
%

mp_unnorm = moments.wi * sum(mod.^ 2);

grad = 2*moments.wi*(moments.m2*mod2 - mp_unnorm*moments.dx)/(moments.m2^2);