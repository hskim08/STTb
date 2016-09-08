function plotModPowerStats( modPowerStats )
%
% Creates a plot for the modulation band power
%

plotImage( modPowerStats );
xlabel('Modband #');
ylabel('Subband #');

colormap(diverge('rwb', 100, 2));