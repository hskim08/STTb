% wipe clean
clear all; clc; close all;

% Load toolkit
addpath('sttb/');
setupToolkit();

%
% In this script, the sound texture statistics are extracted then 
% visualized explicitly from an audio file.
%

% output folder to save stats
outputFolder = 'outputs/stats/';

%% Load audio parameters
audioFolder = 'examples/';

files = {...
    'applause', 'drills', 'stream', 'guitar', 'scary', ...
    'violin' ... 
    };

iFile = 1;
disp( ['Loading ' files{iFile}] );

% create source parameter struct
sourceParams.filename = [files{iFile} '.wav'];
sourceParams.folder = audioFolder;
sourceParams.maxDuration = 10; % use max 10 secs
sourceParams.desiredRMS = .1;


%% Load analysis parameters
analysis_parameters;


%%
% 1. Load audio
%
origSound = loadSound( sourceParams, analysisParams.audio_sr );
nSamples = length( origSound );



%%
% 2. Generate filterbanks
%

%
% Generate audio filters
%
audio_sr = analysisParams.audio_sr;
filterParams = analysisParams.filter.audio;

% generate audio filters
audioFilters = makeERBFilters( nSamples, audio_sr, ...
    filterParams.nChannels, filterParams.lowCutoff, audio_sr/2 );
filterBundle.audioFilters = generateFullFilter( audioFilters, nSamples );


%
% Create temporal window
%
winLength = round( 2 * analysisParams.audio_sr/analysisParams.env_sr );
filterBundle.window = sqrt(hann(winLength, 'periodic')); 
% TODO: the window type should be coded in the analysis parameter

% get frame count
[~, nFrames] = getOLAStepAndCount( nSamples, winLength, 0.5 );


%
% Generate modulation filters
%
env_sr = analysisParams.env_sr;
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




%%
% 3. Generate subbands, subband envelopes & residuals
%

% generate subbands
subbands = generateSubbands( origSound, filterBundle.audioFilters );

% generate subband envelopes
[subbandEnvs, subbandResiduals] = generateSubbandEnvs( subbands, filterBundle.window, ...
    analysisParams.compression);

% merge subband residuals
residuals = renderResidual( subbandResiduals, filterBundle.window, ...
    filterBundle.audioFilters );

% generate modbands
modbands = generateModbands( subbandEnvs, filterBundle.modFilters );
modbandsC2 = generateModbands( subbandEnvs, filterBundle.modC2Filters );




%% 
% 4. Calculate statistics
%

[~, nSubbands, nModbands] = size(modbands);
nModbandsC2 = size(modbandsC2, 3);

%
% Residuals
%
[a, g] = lpc( residuals, analysisParams.residual.lpcOrder );

stats.residual.coeffs = a;
stats.residual.gain = g;

% plot
figure(1);
plotResidualStats( stats.residual, audio_sr, residuals );


%%
% Modulation Spectrum Amplitude
%
modSpectraParams = analysisParams.modspectra;

nFrames = round(env_sr * modSpectraParams.block); 
nStep = round(env_sr * modSpectraParams.step);
nMods = floor(nFrames/2) + 1;

envStack = stackOLA2( subbandEnvs, nFrames, nStep );
modSpectra = fft(envStack);
modSpectra = modSpectra(1:nMods, :, :);

stats.modSpectraAmps = mean(abs(modSpectra), 3); % get average amplitude


%% plot
figure(2);
plotModSpecAmps( stats.modSpectraAmps, env_sr );


%%
% Modulation Power
%
stats.modPower = zeros(nSubbands, nModbands);
for iSubband = 1:nSubbands, % for each subband
    
    cursub = subbandEnvs(:, iSubband);
    
    % subband envelope statistics 
    moments = calculateMoments( cursub );
    
    % subband modulation power
    stats.modPower( iSubband, : ) = calculateModPowerStats( squeeze(modbands(:, iSubband, :)), moments );
end

% plot
figure(3);
plotModPowerStats( stats.modPower );


%%
% Between subband (C1) modulation correlations
%

% Direct correlation
stats.modC1 = calculateModC1StatsFull( modbands );

% plot
figure(4);
plotModC1Stats( stats.modC1, centerFreqs );


% Analytic signal correlation
stats.modC1Analytic = calculateModC1AnalyticStatsFull( modbands );

% plot
figure(5);
plotModC1AnalyticStats( stats.modC1Analytic, 1, centerFreqs );
figure(6);
plotModC1AnalyticStats( stats.modC1Analytic, 0, centerFreqs );


%%
% Within subband (C2) modulation correlations
%

% C2 correlation
stats.modC2 = zeros(nSubbands, nModbandsC2-1, 2);
for iSubband = 1:nSubbands, % for each subband
    stats.modC2(iSubband, :, :) = calculateModC2Stats( squeeze(modbandsC2(:, iSubband, :)) );
end

% plot
figure(7);
plotModC2Stats( stats.modC2 );


% C2 amplitude correlation
stats.modC2Amp = zeros(nSubbands, nModbands, nModbands);
for iSubband = 1:nSubbands, % for each subband
    stats.modC2Amp(iSubband, :, :) = calculateModC2AmpStatsFull( squeeze(modbands(:, iSubband, :)) );
end

% plot
figure(8);
plotModC2AmpStats( stats.modC2Amp );



%% 
% Save statistics to file
%

outFile = [outputFolder files{iFile} '.mat'];
disp(['Saving to: ' outFile]);
save(outFile, 'stats');