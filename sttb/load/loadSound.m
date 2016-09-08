function origSound = loadSound( sourceParams, audio_sr, nSamples )
%
% Loads the audio from the source parameters, then adjusts the sampling 
% rate, length and RMS level of the audio.
%
% Parameters:
%
% Returns:
%
%

if str2double(strtok(version(), '.')) > 7, % newer audio load function
    [temp, sampleRate] = audioread([sourceParams.folder sourceParams.filename]);
else
    [temp, sampleRate] = wavread([sourceParams.folder sourceParams.filename]);
end

if size(temp,2) > 1, % turn stereo files into mono by selecting single channel 
    temp = temp(:,1); 
end

% resample if needed
if sampleRate ~= audio_sr, 
    temp = resample(temp, audio_sr, sampleRate);
end

% adjust length
if ~exist('nSamples', 'var'),
    nSamples = floor( sourceParams.maxDuration * audio_sr );
end

if nSamples <= 0 ...
        || length(temp) < nSamples,
    origSound = temp; % use full signal to measure stats
else
    origSound = temp(1:nSamples);
end

% set to desired RMS level
if sourceParams.desiredRMS > 0,
    origSound = origSound / rms(origSound) * sourceParams.desiredRMS;
end