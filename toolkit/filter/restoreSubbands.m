function synthSubbands = restoreSubbands( subbandEnvs, ...
    subbandResiduals, win, compressionOptions )
%
% Restores the subbands from subband envelopes and residuals.
%

[winLength, nFrames, nSubbands] = size(subbandResiduals);
nSamples = getOLALengthAndStep( winLength, nFrames ); % get length of the subbands

subbandEnvs = decompressEnvelopes( subbandEnvs, compressionOptions );
subbandEnvs = subbandEnvs(1:nFrames, :); % This is a hack. This will cutoff a frame.

% render subbands
synthSubbands = zeros(nSamples, nSubbands);
for iChannel = 1:nSubbands,
    sb_mag = subbandEnvs(:, iChannel);
    sb_wins = subbandResiduals(:, :, iChannel);

    weights = win * sb_mag'; % post-process window    
    
    synth_sb_win = weights .* sb_wins;

    synthSubbands(:, iChannel) = pressOLAStack( synth_sb_win );
end