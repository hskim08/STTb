function modPower = calculateModPowerStatsFull( modbands, subbandEnvs )
%
% Calculates the full modulation power
%

[~, nSubbands, nModbands] = size(modbands);

modPower = zeros(nSubbands, nModbands);
for iSubband = 1:nSubbands, % for each subband
    
    cursub = subbandEnvs(:, iSubband);
    
    % subband envelope statistics 
    moments = calculateMoments( cursub );
    
    % subband modulation power
    modPower( iSubband, : ) = calculateModPowerStats( squeeze(modbands(:, iSubband, :)), moments );
end