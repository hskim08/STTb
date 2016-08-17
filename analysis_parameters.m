% Analysis source parameters
% below is an example
% sourceParams.filename = 'drill.wav';
% sourceParams.folder = 'Example_Textures/';
% sourceParams.maxDuration = 7;
% sourceParams.desiredRMS = .01; 


%% Analysis parameters
analysisParams.verbose = 1; % 0 --> no messages; 1 --> messages are displayed


% sampling rates
analysisParams.audio_sr = 20000; % Audio Sample Rate
analysisParams.env_sr = 400; % Frame Rate (Envelope Sample Rate)


% compression parameters
analysisParams.compression.type = 1; % 0: no compression, 1: power compression, 2: logarithmic compression
analysisParams.compression.exponent = .3; % for power compression
analysisParams.compression.logConstant = 10^-12; % for logarithmic compression. this constant is added prior to taking the log


% filter parameters

% audio filterbank
analysisParams.filter.audio.nChannels = 30; % this is the number excluding lowpass and highpass filters on ends of spectrum
analysisParams.filter.audio.lowCutoff = 20; % Hz - low frequency cutoff

% modulation filterbank
% TODO: cleanup the parameters
analysisParams.filter.modulation.nChannels = 20; % These next four parameters control the modulation filterbank from which modulation power is measured
analysisParams.filter.modulation.lowCutoff = 0.5; % Hz
analysisParams.filter.modulation.Qfactor = 2; % for modulation filters

analysisParams.filter.modulation.lowCutoffC2 = 0.5; % Hz - this is the lowest frequency in the octave-spaced modulation filterbank used for the C1 and C2 correlations


% residual parameters
analysisParams.residual.lpcOrder = 200;


% modulation spectra parameters
analysisParams.modspectra.block = 4; % analysis block(window) size in seconds
analysisParams.modspectra.step = 0.5; % analysis step size in seconds