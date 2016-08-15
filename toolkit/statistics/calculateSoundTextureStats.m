function stats = calculateSoundTextureStats( subbands, subbandEnvs, residuals, ...
    modbands, modbandsC2, analysisParams )

%
% Subband variances
%
stats.subbandVars = var( subbands );


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