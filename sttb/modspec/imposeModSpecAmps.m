function newEnvs = imposeModSpecAmps( envs, modSpectraAmps )
%imposeModSpecAmps    Imposes the modulation spectra amplitude onto the 
% subband envelopes.
%
% Parameters:
% envs - The subband envelopes
% modSpectraAmps - The modulation spectra amplitudes
%
% Returns:
% newEnvs - The new subband envelopes
%

nMods = size(modSpectraAmps, 1);
nFrames = 2*(nMods - 1); % This is a hack.

% get modulation spectra
modSpectra = fft(envs);
modSpectra = modSpectra(1:nMods, :);

% enforce modulation spectra amplitudes
modSpectraAdj = modSpectraAmps .* exp(1i*angle(modSpectra));

% return to TF representation
modSpectraAdjX = expandSpectra( modSpectraAdj, nFrames );

newEnvs = real(ifft(modSpectraAdjX));