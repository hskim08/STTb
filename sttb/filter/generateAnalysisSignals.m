function [subbands, subbandEnvs, residuals, modbands, modbandsC2, subbandResiduals] ...
    = generateAnalysisSignals( origSound, compressionParams, filterBundle )
%generateAnalysisSignals    Generates the signals used for sound texture 
% analysis.
%
% Parameters:
% origSound - A single channel signal
% compressionParams - The compression parameters
% filterBundle - The filter bundle.
%
% Returns:
% subbands - The subband signal. 
% subbandEnvs - The subband envelopes.
% residuals - The signal residuals.
% modbands - The modulation bands.
% modbandsC2 - The modulation bands for C2 calculation.
% subbandResiduals - The subband residuals.
% 
% This is a convenience function for creating the signals used for the
% analysis phase.
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