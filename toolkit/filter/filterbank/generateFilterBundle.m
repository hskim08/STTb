function filterBundle = generateFilterBundle( analysisParams, nSamples, nFrames )
%
% Generates the filters for audio analysis.
%

%
% 1. Generate audio filters
%
audio_sr = analysisParams.audio_sr;
filterParams = analysisParams.filter.audio;

% generate audio filters
audioFilters = makeERBFilters( nSamples, audio_sr, ...
    filterParams.nChannels, filterParams.lowCutoff, audio_sr/2 );
filterBundle.audioFilters = generateFullFilter( audioFilters, nSamples );


%
% 2. Create temporal window
%
winLength = round( 2 * analysisParams.audio_sr/analysisParams.env_sr );
filterBundle.window = sqrt(hann(winLength, 'periodic')); 
% TODO: the window type should be coded in the analysis parameter


% get frame count
if ~exist('nFrames', 'var'),
    [~, nFrames] = getOLAStepAndCount( nSamples, winLength, 0.5 );
end


%
% 3. Generate modulation filters
%
env_sr = analysisParams.env_sr;
filterParams = analysisParams.filter.modulation;

% create modulation filterbank
[modFilters, centerFreqs] = makeCQTFilters( nFrames, env_sr, ...
    filterParams.nChannels, filterParams.lowCutoff, env_sr/2, ...
    filterParams.Qfactor );
filterBundle.modFilters = generateFullFilter( modFilters, nFrames );
filterBundle.modCenterFreqs = centerFreqs;

% create C2 filterbank
modC2filters = makeOctaveBandFilters( nFrames, env_sr, ...
    filterParams.lowCutoffC2, env_sr/2 );
filterBundle.modC2Filters = generateFullFilter( modC2filters, nFrames );
