function modbands = generateModbands( envs, filts )
%
% Generates modulation bands
%

[nFrames, nSubbands] = size(envs);
nModbands = size(filts, 2);

modbands = zeros(nFrames, nSubbands, nModbands);
for iSubband = 1:nSubbands,
    modbands(:, iSubband, :) = generateSubbands( envs(:, iSubband), filts );
end
