function modbands = generateModbands( envs, filts )
%generateModbands    Generates modulation bands.
%
% Parameters:
% envs - Subband envelopes
% filts - The modulation filterbank
%
% Returns:
% modbands - The modulation band signals. 
%

[nFrames, nSubbands] = size(envs);
nModbands = size(filts, 2);

modbands = zeros(nFrames, nSubbands, nModbands);
for iSubband = 1:nSubbands,
    modbands(:, iSubband, :) = generateSubbands( envs(:, iSubband), filts );
end
