function modSpecAmps = calculateModSpecAmps( subbandEnvs, env_sr, modSpectraParams )
%
% Calculates the modulation spectra amplitudes
%

nFrames = round(env_sr * modSpectraParams.block); 
nStep = round(env_sr * modSpectraParams.step);
nMods = floor(nFrames/2) + 1;

envStack = stackOLA2( subbandEnvs, nFrames, nStep );
modSpectra = fft(envStack);
modSpectra = modSpectra(1:nMods, :, :);

modSpecAmps = mean(abs(modSpectra), 3);