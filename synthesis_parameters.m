% Synthesis output settings
% below is an example
% outputParams.desiredRMS = .01;
% outputParams.outputFolder = '~/Temp/output/';


%% Synthesis parameters
synthParams.verbose = 1; % 0 --> no messages 1 --> minimal messages 2 --> very verbose


% impose stats whose variables are set to 1
synthParams.impose.modPower = 0; % Not used. Left for legacy reasons.

synthParams.impose.modC1 = 0; % Not used. Left for legacy reasons.
synthParams.impose.modC1Analytic = 1;

synthParams.impose.modC2 = 1;
synthParams.impose.modC2Amp = 1;
    

% stats calculation parameters
synthParams.modC1Offsets = 1:5; % don't use all parameters, only use the following offsets.
synthParams.modC2AmpOffsets = 8;


% synthesis loop
synthParams.nIterations = 3; % max number of iterations of synthesis loop

synthParams.search.startCount = 10; % start with 10 searches
synthParams.search.maxCount = 30; % maximum of 30 searches