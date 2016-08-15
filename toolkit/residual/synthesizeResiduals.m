function synthResiduals = synthesizeResiduals( x, a, ...
    filterBundle, compressionOptions )
%
% Synthesizes residuals from the residual statistics.
%

% create residual
newResidual = filtfilt(1, a, x); % filtered noise

% generate subbands
newResiduals = generateSubbands( newResidual, filterBundle.audioFilters );

% generate subband envelopes
[~, synthResiduals] = generateSubbandEnvs( newResiduals, ...
    filterBundle.window, compressionOptions );