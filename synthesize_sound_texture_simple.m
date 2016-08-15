% wipe clean
clear all; clc; close all;

% Load toolkit
addpath('toolkit/');
setupToolkit();

%
% In this script, a sound texture sample is synthesized from statistics 
% implicitly.
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

iFile = 5;
disp( ['Loading stats for ' files{iFile}] );

load([statsFolder files{iFile} '.mat']);

% create output parameter struct
outputParams.desiredRMS = .01;
outputParams.outputFolder = '~/Temp/usertest/output/';

%
% Prepare for synthesis
%

% Get constants
audio_sr = analysisParams.audio_sr;
env_sr = analysisParams.env_sr;

nSamples = audio_sr * analysisParams.modspectra.block;
nFrames = env_sr * analysisParams.modspectra.block;

% Generate filterbanks
filterBundle = generateFilterBundle( analysisParams, nSamples, nFrames );

% Initialize samples
synthSound = randn(nSamples, 1); % create Gaussian noise signal


%
% Synthesize envelopes
%
synthEnvs = synthesizeEnvelopes( synthSound, ...
    stats, synthParams, analysisParams, filterBundle );


%
% Synthesize residuals
%
synthResiduals = synthesizeResiduals( synthSound, ...
    stats.residual.coeffs, filterBundle, analysisParams.compression );


%
% Render audio
%

% merge residual and envelopes
synthSubbands = restoreSubbands( synthEnvs, synthResiduals, ...
    filterBundle.window, analysisParams.compression );

% equalize subbands
if synthParams.adjustSubbandVars,
    synthSubbands = adjustSubbands( synthSubbands, stats.subbandVars );
end

% merge subbands
synthAudio = collapseSubbands( synthSubbands, filterBundle.audioFilters );


%% Play audio
y = synthAudio/rms(synthAudio) * outputParams.desiredRMS;
apOut = audioplayer(y, audio_sr);