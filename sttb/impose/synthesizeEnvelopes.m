function [newEnvs, snrs, iterEnvs, envsMSA, envs] = synthesizeEnvelopes( synthSound, stats, ...
    synthParams, analysisParams, filterBundle )
%
% Synthesizes sound texture envelopes from sound texture statistics.
%

% generate subbands
synthSubbands = generateSubbands( synthSound, filterBundle.audioFilters );

% generate subband envelopes
envs = generateSubbandEnvs( synthSubbands, ...
    filterBundle.window, analysisParams.compression );


% Impose modulation spectra amplitudes
envsMSA = imposeModSpecAmps( envs, stats.modSpectraAmps );


% Modulation spectra phase modeling
c1Offsets = flipArrays( synthParams.modC1Offsets );
c2Offsets = synthParams.modC2AmpOffsets;

iterEnvs = envsMSA;
snrs = cell(synthParams.nIterations, 1);
for iIteration = 1:synthParams.nIterations,

    if synthParams.verbose > 0,
        disp(['Iteration ' num2str(iIteration)]);
    end
    
    % impose C1/C2 stats
    [iterEnvs, snr] = imposeEnvStats( iterEnvs, stats, ...
        synthParams.impose, filterBundle, c1Offsets, c2Offsets, ...
        analysisParams, synthParams.search, iIteration, synthParams.verbose );
    
    snrs{iIteration} = snr;
    
    if synthParams.verbose > 0,
        disp(' '); % linebreak for readability
    end
end


% Reinforce modulation spectra amplitudes
newEnvs = imposeModSpecAmps( iterEnvs, stats.modSpectraAmps );