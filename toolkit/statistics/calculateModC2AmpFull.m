function modC2Amp = calculateModC2AmpFull( modbands )
%
% Calculates the full within subband (C2) amplitude correlation
%

[~, nSubbands, nModbands] = size(modbands);

modC2Amp = zeros(nSubbands, nModbands, nModbands);
for iSubband = 1:nSubbands, % for each subband
    modC2Amp(iSubband, :, :) = calculateModC2AmpStatsFull( squeeze(modbands(:, iSubband, :)) );
end