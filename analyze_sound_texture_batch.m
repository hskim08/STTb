% wipe clean
clear all; clc; close all;

% Load toolkit
addpath('toolkit/');
setupToolkit();

%
% In this script, the sound texture statistics are extracted then 
% saved to a folder.
%

% Load analysis parameters
analysis_parameters;

% Output folder
outputFolder = '~/Temp/usertest/stats/';


%% Load audio parameters
audioFolder = '../toolkit/Example_Textures/';

files = {...
    'rain', 'train', 'bees', 'wind', 'drills' ... % 5
    'applause', 'bubbles', 'babble', 'stream', 'fire', ... % 10
    'swamp', 'gravel', 'helicopter', 'glass_chimes', 'windchimes', ... % 15
    'glass_shards', 'tuning', 'violin', 'scary', 'scary2', ... % 20
    'guitar_sample', 'guitar_clean_1', 'guitar_clean_2', 'guitar_dist_2', 'guitar_dist_3'... % 25
    'ride_low', 'ride_hi', 'drumroll_1', 'drumroll_2', 'purring', ...
    };
nFiles = length(files);

for iFile = nFiles, %1:nFiles,
    
    disp( ['Loading ' files{iFile}] );

    % create source parameter struct
    sourceParams.filename = [files{iFile} '.wav'];
    sourceParams.folder = audioFolder;
    sourceParams.maxDuration = 10; % use max 10 secs
    sourceParams.desiredRMS = .1;

    % 1. Load audio
    origSound = loadSound( sourceParams, analysisParams.audio_sr );
    nSamples = length( origSound );

    % 2. Generate filterbanks
    filterBundle = generateFilterBundle( analysisParams, nSamples );

    % 3. Generate subbands, subband envelopes & residuals
    [subbands, subbandEnvs, residuals, modbands, modbandsC2] ...
        = generateAnalysisSignals( origSound, analysisParams.compression, ...
        filterBundle );

    % 4. Calculate statistics
    stats = calculateSoundTextureStats( subbandEnvs, residuals, ...
        modbands, modbandsC2, analysisParams );

    % 5. Save stats to file
    outFile = [outputFolder files{iFile} '.mat'];
    disp(['Saving to: ' outFile]);
    save(outFile, 'stats');

end