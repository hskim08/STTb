% wipe clean
clear all; clc; close all;

% Load toolkit
addpath('toolkit/');
setupToolkit();

%
% In this script the sound texture statistics are extracted then visualized
% implicitly from an audio file.
%

%% Load audio parameters

audioFolder = '../toolkit/Example_Textures/';

files = {...
    'rain', 'train', 'bees', 'wind', 'drills' ... % 5
    'applause', 'bubbles', 'babble', 'stream', 'fire', ... % 10
    'swamp', 'gravel', 'helicopter', 'glass_chimes', 'windchimes', ... % 15
    'glass_shards', 'tuning', 'violin', 'scary', 'scary2', ... % 20
    'guitar_sample', 'guitar_clean_1', 'guitar_clean_2', 'guitar_dist_2', 'guitar_dist_3'... % 25
    'ride_low', 'ride_hi', 'drumroll_1', 'drumroll_2', ...
    };

iFile = 19;
disp( ['Loading ' files{iFile}] );

% create source parameter struct
sourceParams.filename = [files{iFile} '.wav'];
sourceParams.folder = audioFolder;
sourceParams.maxDuration = 10; % use max 10 secs
sourceParams.desiredRMS = .1;


%% Calculate sound texture statistics

% Load analysis parameters
analysis_parameters;

% 1. Load audio
origSound = loadSound( sourceParams, analysisParams.audio_sr );
nSamples = length( origSound );

% 2. Generate filterbanks
filterBundle = generateFilterBundle( analysisParams, nSamples );

% 3. Generate subbands, subband envelopes, residuals, & modulation bands
[subbands, subbandEnvs, residuals, modbands, modbandsC2] ...
    = generateAnalysisSignals( origSound, analysisParams.compression, ...
    filterBundle );

% 4. Calculate statistics
stats = calculateSoundTextureStats( subbands, subbandEnvs, residuals, ...
    modbands, modbandsC2, analysisParams );


%% Plot statistics

[nFrames, nSubbands, nModbands] = size(modbands);
nModbandsC2 = size(modbandsC2, 3);
centerFreqs = filterBundle.modCenterFreqs;

% Residuals
figure(1);
plotResidualStats( stats.residual, analysisParams.audio_sr, residuals );

% Modulation Spectra Amplitudes
figure(2);
plotModSpecAmps( stats.modSpectraAmps, analysisParams.env_sr );


% Modulation Power
figure(3);
plotModPowerStats( stats.modPower );

% C1 - Direct correlation
figure(4);
plotModC1Stats(stats.modC1, centerFreqs);

% C1 - Analytic signal correlation
figure(5);
plotModC1AnalyticStats( stats.modC1Analytic, 1, centerFreqs );
figure(6);
plotModC1AnalyticStats( stats.modC1Analytic, 0, centerFreqs );

% C2 correlation
figure(7);
plotModC2Stats( stats.modC2 );

% C2 amplitude correlation
figure(8);
plotModC2AmpStats( stats.modC2Amp );