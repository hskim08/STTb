% wipe clean
clear all; clc; close all;

% Load toolkit
addpath('sttb/');
setupToolkit();

%
% In this script, a sound texture sample is synthesized from statistics 
% implicitly.
%

%% Load parameters
analysis_parameters;
synthesis_parameters;

%% Load stats
statsFolder = 'outputs/stats/';

files = {...
    'applause', 'drills', 'stream', 'guitar', 'scary', ...
    'violin' ...
    };

iFile = 1;
disp( ['Loading stats for ' files{iFile}] );

load([statsFolder files{iFile} '.mat']);

% create output parameter struct
outputParams.desiredRMS = .01;
outputParams.outputFolder = 'outputs/audio/';

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

% merge subbands
synthAudio = collapseSubbands( synthSubbands, filterBundle.audioFilters );


%% Play audio
y = synthAudio/rms(synthAudio) * outputParams.desiredRMS;
apOut = audioplayer(y, audio_sr);