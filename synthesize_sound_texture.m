% wipe clean
clear all; clc; close all;

% Load toolkit
addpath('toolkit/');
setupToolkit();

%
% In this script, a sound texture sample is synthesized from statistics 
% explicitly.
%

%% Load parameters
analysis_parameters;
synthesis_parameters;

%% Load stats
statsFolder = '~/Temp/usertest/stats/';

files = {...
    'rain', 'train', 'bees', 'wind', 'drills' ... % 5
    'applause', 'bubbles', 'babble', 'stream', 'fire', ... % 10
    'swamp', 'gravel', 'helicopter', 'glass_chimes', 'windchimes', ... % 15
    'glass_shards', 'tuning', 'violin', 'scary', 'scary2', ... % 20
    'guitar_sample', 'guitar_clean_1', 'guitar_clean_2', 'guitar_dist_2', 'guitar_dist_3'... % 25
    'ride_low', 'ride_hi', 'drumroll_1', 'drumroll_2', ...
    };

iFile = 19;
disp( ['Loading stats for ' files{iFile}] );

load([statsFolder files{iFile} '.mat']);

% create output parameter struct
outputParams.desiredRMS = .01;
outputParams.outputFolder = '~/Temp/usertest/output/';


%% Get constants

audio_sr = analysisParams.audio_sr;
env_sr = analysisParams.env_sr;

nSamples = audio_sr * analysisParams.modspectra.block;
nFrames = env_sr * analysisParams.modspectra.block;

[nSubbands, ~] = size(stats.modPower);


%% Create audio filters

filterParams = analysisParams.filter.audio;

% generate audio filters
audioFilters = makeERBFilters( nSamples, audio_sr, ...
    filterParams.nChannels, filterParams.lowCutoff, audio_sr/2 );
filterBundle.audioFilters = generateFullFilter( audioFilters, nSamples );

% create temporal window
winLength = round( 2 * audio_sr/env_sr );
filterBundle.window = sqrt(hann(winLength, 'periodic')); % TODO: the window type should be coded in the analysis parameter


%% Generate subbands and subband envelopes

% Initialize samples
synthSound = randn(nSamples, 1); % create Gaussian noise signal

% generate subbands
synthSubbands = generateSubbands(synthSound, filterBundle.audioFilters);

% generate subband envelopes
[subbandEnvs, subbandResiduals] = generateSubbandEnvs( synthSubbands, ...
    filterBundle.window, analysisParams.compression);

% plot
figure(1);
t = (1:nFrames)/env_sr;
plotImage(t, 1:nSubbands, subbandEnvs');
colormap(diverge('rwb', 100, 2));
title('Initialized Signal');
ylabel('Subband #');
xlabel('Time (sec)');


%% Impose modulation spectra amplitudes

modSpectraAmps = stats.modSpectraAmps;
nMods = size(modSpectraAmps, 1);

% get modulation spectra
modSpectra = fft(subbandEnvs);
modSpectra = modSpectra(1:nMods, :);

% enforce modulation spectra amplitudes
modSpectraAdj = modSpectraAmps .* exp(1i*angle(modSpectra));

% return to TF representation
modSpectraAdjX = expandSpectra( modSpectraAdj, nFrames );
subbandEnvs2 = real(ifft(modSpectraAdjX));


% plot
figure(2);
t = (1:nFrames)/env_sr;
plotImage(t, 1:nSubbands, subbandEnvs2');
colormap(diverge('rwb', 100, 2));
title('Mod. Spectra Amp. Imposed');
ylabel('Subband #');
xlabel('Time (sec)');


%% Create modulation filters

% prepare for C1/C2 impose
c1Offsets = flipArrays( synthParams.modC1Offsets );

filterParams = analysisParams.filter.modulation;

% create modulation filterbank
[modFilters, centerFreqs] = makeCQTFilters( nFrames, env_sr, ...
    filterParams.nChannels, filterParams.lowCutoff, env_sr/2, ...
    filterParams.Qfactor );
filterBundle.modFilters = generateFullFilter( modFilters, nFrames );

% create C2 filterbank
modC2filters = makeOctaveBandFilters( nFrames, env_sr, ...
    filterParams.lowCutoffC2, env_sr/2 );
filterBundle.modC2Filters = generateFullFilter( modC2filters, nFrames );


%% Impose C1/C2 correlations for modulation spectra phase modeling

newEnvs = subbandEnvs2;

for iIteration = 1:synthParams.nIterations,

    disp(['Iteration ' num2str(iIteration)]);
    
    % impose C1/C2 stats
    newEnvs = imposeEnvStats( newEnvs, stats, ...
        synthParams.impose, filterBundle, c1Offsets, synthParams.modC2AmpOffsets, ...
        analysisParams, synthParams.search, iIteration, synthParams.verbose );
end

% plot
figure(3);
t = (1:nFrames)/env_sr;
plotImage(t, 1:nSubbands, newEnvs');
colormap(diverge('rwb', 100, 2));
title('Mod. Spectra Amp. Imposed + C1/C2 aligned');
ylabel('Subband #');
xlabel('Time (sec)');


%% Reinforce modulation spectra amplitudes

nMods = size(modSpectraAmps, 1);

% get mod spectra
modSpectra = fft(newEnvs);
modSpectra = modSpectra(1:nMods, :);

% enforce modulation spectra amplitudes
modSpectraAdj = modSpectraAmps .* exp(1i*angle(modSpectra));

% return to TF representation
modSpectraAdjX = expandSpectra( modSpectraAdj, nFrames );
newEnvs2 = real(ifft(modSpectraAdjX));

% plot
figure(4);
t = (1:nFrames)/env_sr;
plotImage(t, 1:nSubbands, newEnvs2');
colormap(diverge('rwb', 100, 2));
title('Mod. Spectra Amp. Imposed + C1/C2 aligned + MSAmp Reinforced');
ylabel('Subband #');
xlabel('Time (sec)');


%% Synthesize residuals

a = stats.residual.coeffs;
x = randn(nSamples, 1);

% create residual
newResidual = filtfilt(1, a, x); % filtered noise
newResiduals = generateSubbands( newResidual, filterBundle.audioFilters );

% generate subband envelopes
[~, synthResiduals] = generateSubbandEnvs( newResiduals, ...
    filterBundle.window, analysisParams.compression);


%% Merge residuals with envelopes
nFramesAdj = size(synthResiduals, 2);

% merge residual and envelopes
synthSubbands = restoreSubbands( newEnvs2, synthResiduals, ...
    filterBundle.window, analysisParams.compression );

synthAudio = collapseSubbands( synthSubbands, filterBundle.audioFilters );


%% Play audio
y = synthAudio/rms(synthAudio) * outputParams.desiredRMS;
apOut = audioplayer(y, audio_sr);