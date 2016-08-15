function [subbandEnvs, subbandResiduals] = generateSubbandEnvs( subbands, ...
    win, compressionOptions )
%
% Generates envelopes from subbands by calculating power of windowed
% segments.
%
% Parameters:
%   subbands - the subband signals. each column is a subband
%   audio_sr - the audio sampling rate
%   env_sr - the envelope sampling rate aka the frame rate
%   compression_options - the compression options
%
% Returns:
%   subbandEnvs - the subband envelopes
%   subband_wins - the windowed signal normalized by power
%

verySmallValue = 10^-12; % to prevent divide by zero

winLength = length(win);

sum_w = wmag( win, 1 );

% get windowed signal
[nSamples, nSubbands] = size(subbands);
[~, nFrames] = getOLAStepAndCount( nSamples, winLength, 0.5 );

subbandEnvs = zeros(nFrames, nSubbands);
subbandResiduals = zeros(winLength, nFrames, nSubbands);
for iSubband = 1:nSubbands,
    subband_flat = stackOLA( subbands(:, iSubband), winLength );
    subband_win = ( win * ones(1, size(subband_flat, 2)) ) .* subband_flat; % pre-process window
    
    subband_mag = wmag( subband_win, sum_w ); % weighted power, removes effect of window
    subband_mag(subband_mag < verySmallValue) = verySmallValue; % prevent divide by zero
    
    subbandEnvs(:, iSubband) = subband_mag;
    subbandResiduals(:, :, iSubband) = subband_win ./ ...
        ( ones(size(subband_win, 1), 1) * subband_mag ); % windowed signal normalized by magnitude
end

% compress the envelopes
subbandEnvs = compressEnvelopes( subbandEnvs, compressionOptions );
