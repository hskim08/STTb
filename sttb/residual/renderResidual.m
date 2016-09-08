function residuals = renderResidual( subbandResiduals, win, audioFilters )
%
% Renders the residual stack into audio
%

[nWin, nFrames, nChannels] = size(subbandResiduals);
nSamples = getOLALengthAndStep( nWin, nFrames );

% render subbands
residualSubbands = zeros(nSamples, nChannels);
for iChannel = 1:nChannels,
    weights = win * ones(1, nFrames); % post-process window
    synth_sb_win = weights .* subbandResiduals(:, :, iChannel);

    residualSubbands(:, iChannel) = pressOLAStack( synth_sb_win );
end

residualSubbands = residualSubbands(1:size(audioFilters, 1), :); % match length just in case
residuals = collapseSubbands( residualSubbands, audioFilters ); % resynthesize carrier
