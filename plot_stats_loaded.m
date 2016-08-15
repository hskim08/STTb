% wipe clean
clear all; clc; close all;

% Load toolkit
addpath('toolkit/');
setupToolkit();

%
% In this script, the sound texture statistics are loaded from a previous
% file and visualized.
%

%% Load audio parameters
statsFolder = '~/Temp/usertest/';

files = {...
    'rain', 'train', 'bees', 'wind', 'drills' ... % 5
    'applause', 'bubbles', 'babble', 'stream', 'fire', ... % 10
    'swamp', 'gravel', 'helicopter', 'glass_chimes', 'windchimes', ... % 15
    'glass_shards', 'tuning', 'violin', 'scary', 'scary2', ... % 20
    'guitar_sample', 'guitar_clean_1', 'guitar_clean_2', 'guitar_dist_2', 'guitar_dist_3'... % 25
    'ride_low', 'ride_hi', 'drumroll_1', 'drumroll_2', ...
    };

iFile = 18;
disp( ['Loading stats for ' files{iFile}] );

load([statsFolder files{iFile} '.mat']);


%%
% Plot statistics
%

% Residuals
figure(1);
plotResidualStats( stats.residual );

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