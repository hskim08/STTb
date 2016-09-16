function [newEnvs, snr, errorLog] = imposeEnvStats( envs, stats, imposeParams, filters, ...
    c1Offsets, c2AmpOffsets, analysisParams, searchParams, iteration, verbose )
%imposeEnvStats    Impose target statistics to the current envelope.
%
% Parameters:
% envs - The subband envelopes
% stats - The target statistics
% imposeParams - The impose parameters
% filters - The filter bundle
% c1Offsets - The C1 offsets to use
% c2AmpOffsets - The offsets to use for the C2 amplitude imposing
% analysisParams - The analysis parameters
% searchParams - The search parameters
% iteration - The number of iterations to run
% verbose - The verbosity level
% 
% Returns:
% cost - The cost (errors)
% grad - The gradients
%

if ~exist('verbose', 'var'),
    verbose = 0;
end

t = tic;

nLineSearch = min(searchParams.startCount + iteration, searchParams.maxCount);

% set order to go through subbands
nSubbands = size(stats.modSpectraAmps, 2);

subbandPower = sum(stats.modSpectraAmps.^2, 1);
[~, startingSub] = max(subbandPower);
subOrder = getSubOrder( startingSub, nSubbands );
nSubOrders = length(subOrder);


% Pre-calculate modulations
newEnvs = envs;

modFilter = filters.modFilters;
modBands = generateModbands( newEnvs, modFilter );
modBandsFiltered = applyModFilterParallel( modBands, modFilter );


% impose
errorLog.start = zeros(nSubOrders, 1);
errorLog.end = zeros(nSubOrders, 1);

for iSubOrder = 1:nSubOrders, % run through the subbands
    
    iSubband = subOrder(iSubOrder); % current subband number
    currentSubbandEnv = newEnvs(:, iSubband); % subband envelope to update
    
    if verbose > 1,
        disp([num2str(iSubOrder) ': subband ' num2str(iSubband)]);
    end
    
    % prepare for modC1
    if imposeParams.modC1 ...
        || imposeParams.modC1Analytic, 
        % correlations to be enforced
        potentialBands = c1Offsets + iSubband; 
        modC1BandsToUse = getBandsToUse(iSubOrder, potentialBands, subOrder);
    else
        modC1BandsToUse = [];
    end

    
    % minimize
    [updatedSubbandEnv, costHistory, iter_run] = minimize( ...
        currentSubbandEnv, ...
        'getCostAndGradient', nLineSearch, ... 
        stats, imposeParams, filters, iSubband, ...
        modC1BandsToUse, c2AmpOffsets, ...
        modBands, modBandsFiltered ...
    );

    if verbose > 1,
        disp(['Iterations: ' num2str(iter_run)]);
    end

    % force envelope to be positive
    updatedSubbandEnv = cleanupSubbands( updatedSubbandEnv, ...
        analysisParams.compression.type, ...
        analysisParams.compression.logConstant );

    
    % update the current subband envelope
    newEnvs(:, iSubband) = updatedSubbandEnv;
    
    % update modulation bands - this is for speeding up the calculations
    modBands(:, iSubband, :) = generateSubbands( updatedSubbandEnv, modFilter );
    modBandsFiltered(:, iSubband, :) = applyFilterParallel( ...
        squeeze(modBands(:, iSubband, :)), modFilter );
    
    
    % optionally save error
    errorLog.start(iSubband) = log10(costHistory(1)); 
    errorLog.end(iSubband) = log10(costHistory(end));

    if verbose > 1,
        disp(['Error start->end: ' ...
            num2str(errorLog.start(iSubband), '%.2f') ...
            ' -> ' ...
            num2str(errorLog.end(iSubband), '%.2f') ...
            ]);
    end
end


% Report statistics
if verbose > 0,
    toc(t) % report time
end

% Evaluate new envelopes
% TODO: only evaluate actually used values, not the whole matrix.
if imposeParams.modC1,
    modC1 = calculateModC1StatsFull( modBands );
    df = stats.modC1 - modC1;
    snr.modC1 = 20*log10(rms(df(:)) / rms(stats.modC1(:)));

    if verbose > 0,
        disp(['C1: ' num2str(snr.modC1, '%.3f ') ' dB']);
    end
end

if imposeParams.modC1Analytic,
    modC1Analytic = calculateModC1AnalyticStatsFull( modBands );
    df = stats.modC1Analytic - modC1Analytic;
    snr.modC1Analytic = 20*log10(rms(df(:)) / rms(stats.modC1Analytic(:)));
    
    if verbose > 0,
        disp(['C1 Analytic: ' num2str(snr.modC1Analytic, '%.3f ') ' dB']);
    end
end

if imposeParams.modC2,
    modbandsC2 = generateModbands( newEnvs, filters.modC2Filters );

    modC2 = calculateModC2StatsFull( modbandsC2 );
    df = stats.modC2 - modC2;
    snr.modC2 = 20*log10(rms(df(:)) / rms(stats.modC2(:)));

    if verbose > 0,
        disp(['C2: ' num2str(snr.modC2, '%.3f') ' dB']);
    end
end

if imposeParams.modC2Amp,
    modC2Amp = calculateModC2AmpFull( modBands );
    df = stats.modC2Amp - modC2Amp;
    snr.modC2Amp = 20*log10(rms(df(:)) / rms(stats.modC2Amp(:)));

    if verbose > 0,
        disp(['C2Amp: ' num2str(snr.modC2Amp, '%.3f') ' dB']);
    end
end


%
% Returns bands to use
%
function bandsToUse = getBandsToUse( iSubOrder, potentialBands, subOrder )

bandsToUse = [];
for b = 1:length(potentialBands),
    if any( potentialBands(b) == subOrder(1:(iSubOrder-1)) ),
        bandsToUse = [bandsToUse potentialBands(b)];
    end
end

%
% Validates subband minimum value
%
function subband = cleanupSubbands( subband, compType, logConstant )
if compType == 0 || compType == 1,
    subband(subband < 0) = 0; 
elseif compType == 2,
    subband(subband < logConstant) = logConstant;
end


%
% Apply filters in parallel to modulation band signals
%
function modfilt = applyModFilterParallel( modbands, filts )

[nFrames, nSubbands, nModbands] = size(modbands);

modfilt = zeros(nFrames, nSubbands, nModbands);

for iSubband = 1:nSubbands,
    modfilt(:, iSubband, :) = applyFilterParallel( ...
        squeeze( modbands(:, iSubband, :) ), filts);
end
