% wipe clean
clear all; clc; close all;

% Load toolkit
addpath('toolkit/');
setupToolkit();

%
% Creates user test samples that don't use synthesis
%

outputFolder = '~/Temp/usertest/output/';

%% Load audio parameters
audioFolder = '../toolkit/Example_Textures/';

files = {...
    'rain', 'train', 'bees', 'wind', 'drills' ... % 5
    'applause', 'bubbles', 'babble', 'stream', 'fire', ... % 10
    'swamp', 'gravel', 'helicopter', 'glass_chimes', 'windchimes', ... % 15
    'glass_shards', 'tuning', 'violin', 'scary', 'scary2', ... % 20
    'guitar_sample', 'guitar_clean_1', 'guitar_clean_2', 'guitar_dist_2', 'guitar_dist_3'... % 25
    'ride_low', 'ride_hi', 'drumroll_1', 'drumroll_2', 'purring'...
    };

for iFile = 1:length(files),
disp( ['Loading ' files{iFile}] );

% create source parameter struct
sourceParams.filename = [files{iFile} '.wav'];
sourceParams.folder = audioFolder;
sourceParams.maxDuration = 30;
sourceParams.desiredRMS = .05;


%% Load analysis parameters
analysis_parameters;

nBlockSamples = analysisParams.audio_sr * analysisParams.modspectra.block;
audio_sr = analysisParams.audio_sr;


% Load audio
origSound = loadSound( sourceParams, analysisParams.audio_sr );
nSamples = length( origSound );

% save original sample
x = origSound(1:nBlockSamples);
x = x/rms(x) * sourceParams.desiredRMS;
outFile = [files{iFile} '_orig' '.wav'];

writeAudioFile( x, audio_sr, [outputFolder outFile] );
disp(['Saved ' outFile]);

% save different region
x = origSound((1:nBlockSamples) + (nSamples-nBlockSamples));
x = x/rms(x) * sourceParams.desiredRMS;
outFile = [files{iFile} '_samp' '.wav'];

writeAudioFile( x, audio_sr, [outputFolder outFile] );
disp(['Saved ' outFile]);


%% Get sound texture statistics
filterBundle = generateFilterBundle( analysisParams, nSamples );

[subbands, subbandEnvs, residuals, modbands, modbandsC2, subbandResiduals] ...
    = generateAnalysisSignals( origSound, analysisParams.compression, filterBundle );

% Calculate statistics
% Subband variances
stats.subbandVars = var( subbands );

% Residuals
[a, g] = lpc( residuals, analysisParams.residual.lpcOrder );
stats.residual.coeffs = a;
stats.residual.gain = g;

% Modulation Spectrum Amplitude
stats.modSpectraAmps = calculateModSpecAmps( subbandEnvs, ...
    analysisParams.env_sr, analysisParams.modspectra ); 


%% Impose modulation spectra amplitudes
synthBundle = generateFilterBundle( analysisParams, nBlockSamples );

envsMSA = imposeModSpecAmps( subbandEnvs, stats.modSpectraAmps );
nFrames = size(envsMSA, 1) - 1;

% use sample residuals
synthResiduals = subbandResiduals(:, 1:nFrames, :);

% merge residual and envelopes
msaSubbands = restoreSubbands( envsMSA, synthResiduals, ...
    synthBundle.window, analysisParams.compression );

% equalize subbands
msaSubbands = adjustSubbands( msaSubbands, stats.subbandVars );

% merge subbands
x = collapseSubbands( msaSubbands, synthBundle.audioFilters );
x = x/rms(x) * sourceParams.desiredRMS;
outFile = [files{iFile} '_msa' '.wav'];

writeAudioFile( x, audio_sr, [outputFolder outFile] );
disp(['Saved ' outFile]);


%% Impose modulation spectra amplitudes + use synthesized residuals

% Synthesize residuals
synthResiduals = synthesizeResiduals( randn(nBlockSamples, 1), ...
    stats.residual.coeffs, synthBundle, analysisParams.compression );

% merge residual and envelopes
msaResSubbands = restoreSubbands( envsMSA, synthResiduals, ...
    synthBundle.window, analysisParams.compression );

% equalize subbands
msaResSubbands = adjustSubbands( msaResSubbands, stats.subbandVars );

% merge subbands
x = collapseSubbands( msaResSubbands, synthBundle.audioFilters );
x = x/rms(x) * sourceParams.desiredRMS;
outFile = [files{iFile} '_res' '.wav'];

writeAudioFile( x, audio_sr, [outputFolder outFile] );
disp(['Saved ' outFile]);


%% Filtered noise
[a, g] = lpc( origSound, analysisParams.residual.lpcOrder );
x = filter(1, a, randn(nBlockSamples, 1)*g); % filtered noise

x = x/rms(x) * sourceParams.desiredRMS;
outFile = [files{iFile} '_filt' '.wav'];

writeAudioFile( x, audio_sr, [outputFolder outFile] );
disp(['Saved ' outFile]);

% low order model
[a, g] = lpc( origSound, 10 );
x = filter(1, a, randn(nBlockSamples, 1)*g); % filtered noise

x = x/rms(x) * sourceParams.desiredRMS;
outFile = [files{iFile} '_filt_lo' '.wav'];

writeAudioFile( x, audio_sr, [outputFolder outFile] );
disp(['Saved ' outFile]);


%%
disp(' ');
end