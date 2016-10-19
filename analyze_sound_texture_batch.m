% wipe clean
clear all; clc; close all;

% Load toolkit
addpath('sttb/');
setupToolkit();

%
% In this script, the sound texture statistics are extracted then saved to 
% a folder.
%

% Load analysis parameters
analysis_parameters;

% Output folder
outputFolder = 'outputs/stats/';


%% Load audio parameters
audioFolder = 'examples/';

files = {...
    'applause', 'drills', 'stream', 'guitar', 'scary', ...
    'violin' ... 
    };

nFiles = length(files);

for iFile = 1:nFiles,
    
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
