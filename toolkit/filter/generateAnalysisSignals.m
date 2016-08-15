function [subbands, subbandEnvs, residuals, modbands, modbandsC2, subbandResiduals] ...
    = generateAnalysisSignals( origSound, compressionParams, filterBundle )
%
% Generates the signals used for sound texture analysis
%

% generate subbands
subbands = generateSubbands( origSound, filterBundle.audioFilters );

% generate subband envelopes
[subbandEnvs, subbandResiduals] = generateSubbandEnvs( subbands, filterBundle.window, ...
    compressionParams);

% merge subband residuals
residuals = renderResidual( subbandResiduals, filterBundle.window, ...
    filterBundle.audioFilters );

% generate modbands
modbands = generateModbands( subbandEnvs, filterBundle.modFilters );
modbandsC2 = generateModbands( subbandEnvs, filterBundle.modC2Filters );