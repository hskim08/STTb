function [newEnvs, snrs, iterEnvs, envsMSA, envs] = synthesizeEnvelopes( synthSound, stats, ...
    synthParams, analysisParams, filterBundle )
%synthesizeEnvelopes    Synthesizes sound texture envelopes from sound 
% texture statistics.
%
% Parameters:
% synthSound - The input sound
% stats - The target statistics
% synthParams - The synthesis parameters
% analysisParams - The analysis parameters
% filterBundle - The filter bundle
%
% Returns:
% newEnvs - The synthesized envelope
% snrs - The SNR of the errors.
% iterEnvs - (Optional) The envelopes after phase imposing without post 
%   modulation spectra amplitudes imposed. For comparison purposes.
% envsMSA - (Optional) The envelopes with only modulation spectra 
%   amplitudes imposed. For comparison purposes.
% envs - The pre-imposed envelopes. For comparison purposes.
%
% This is a convenience function that handles the full process of
% synthesizings the envelopes.
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