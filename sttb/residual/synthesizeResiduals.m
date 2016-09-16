function synthResiduals = synthesizeResiduals( x, a, ...
    filterBundle, compressionOptions )
%synthesizeResiduals    Synthesizes residuals from the residual statistics.
%
% Parameters:
% x - The input signal (noise)
% a - The AR coefficients
% filterBundle - The filter bundle
% compressionOptions - Compression options
%
% Returns:
% synthResiduals - The synthesized residual signal. 
%

% create residual
newResidual = filtfilt(1, a, x); % filtered noise

% generate subbands
newResiduals = generateSubbands( newResidual, filterBundle.audioFilters );

% generate subband envelopes
[~, synthResiduals] = generateSubbandEnvs( newResiduals, ...
    filterBundle.window, compressionOptions );