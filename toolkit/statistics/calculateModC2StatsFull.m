function modC2 = calculateModC2StatsFull( modbandsC2 )
%
% Calculates the full within subband (C2) correlation
%

[~, nSubbands, nModbands] = size(modbandsC2);

modC2 = zeros(nSubbands, nModbands-1, 2);
for iSubband = 1:nSubbands, % for each subband
    modC2(iSubband, :, :) = calculateModC2Stats( squeeze(modbandsC2(:, iSubband, :)) );
end