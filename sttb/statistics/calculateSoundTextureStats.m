function stats = calculateSoundTextureStats( subbandEnvs, residuals, ...
    modbands, modbandsC2, analysisParams )
%calculateSoundTextureStats    Calculates the texture statistics.
%
% Parameters:
% subbandEnvs - The subband envelopes
% residuals - The residual signal
% modbands - The modulation bands
% modbandsC2 - The modulations bands for C2
% analysisParams - The analysis parameters
%
% Returns:
% stats - The sound texture statistics. 
%
% This is a convenience function that calculates all sound texture
% statistics needed for synthesis.
% 


%
% Residuals
%
[a, g] = lpc( residuals, analysisParams.residual.lpcOrder );
stats.residual.coeffs = a;
stats.residual.gain = g;


%
% Modulation Spectrum Amplitude
%
stats.modSpectraAmps = calculateModSpecAmps( subbandEnvs, ...
    analysisParams.env_sr, analysisParams.modspectra ); 


%
% Modulation Power
%
stats.modPower = calculateModPowerStatsFull( modbands, subbandEnvs );


%
% Between subband (C1) modulation correlations
%
% Direct correlation
stats.modC1 = calculateModC1StatsFull( modbands );
% Analytic signal correlation
stats.modC1Analytic = calculateModC1AnalyticStatsFull( modbands );


%
% Within subband (C2) modulation correlations
%

% C2 correlation
stats.modC2 = calculateModC2StatsFull( modbandsC2 );
% C2 amplitude correlation
stats.modC2Amp = calculateModC2AmpFull( modbands );