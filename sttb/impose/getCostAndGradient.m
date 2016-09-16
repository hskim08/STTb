function [cost, grad] = getCostAndGradient( currentSubbandEnv, ...
    stats, imposeParams, filters, currentSubband, modC1BandsToUse, c2AmpOffsets, ...
    modBands, modBandsFiltered )
%getCostAndGradient    Calculates the cost and gradient for minimization.
%
% Parameters:
% currentSubbandEnv - The subband envelope currently being optimized
% stats - The target statistics
% imposeParams - The impose parameters
% filters - The filter bundle.
% currentSubband - The current subband number
% modC1BandsToUse - The between subbands to use for C1 imposing
% c2AmpOffsets - The offsets to use for the C2 amplitude imposing
% modBands - The precalculated modulation bands. (For performance speed up)
% modBandsFiltered - The precalculated filtered modulation bands. (For 
%   performance speed up)
% 
% Returns:
% cost - The cost (errors)
% grad - The gradients
%

%
% 1. Get errors and gradients
%
allGrads = [];
allErrors = [];

% pre-calculate modulation signals
if imposeParams.modPower ...
        || imposeParams.modC1 ...
        || imposeParams.modC1Analytic ...
        || imposeParams.modC2Amp,
    
    modFilter = filters.modFilters;
    
    modSubbands = generateSubbands( currentSubbandEnv, modFilter );
    modSubbands2 = applyFilterParallel( modSubbands, modFilter );
end


% Modulation Power
if imposeParams.modPower,
    
    moments = calculateMoments( currentSubbandEnv );

    [errors, grads] = getModPowerErrorAndGradients( currentSubband, stats, ...
        modSubbands, modSubbands2, moments );

    allErrors = [allErrors errors];
    allGrads = [allGrads grads]; 
end


% C1 correlation
if imposeParams.modC1 ... % mod_C1
    && ~isempty(modC1BandsToUse),

    % get modulation bands for select subbands
    corrMods = modBands(:, modC1BandsToUse, :);
    corrMods2 = modBandsFiltered(:, modC1BandsToUse, :);
    
    [errors, grads] = getC1ErrorAndGradients( currentSubband, stats, ...
        modSubbands, modSubbands2, corrMods, corrMods2, modC1BandsToUse );

    allErrors = [allErrors errors];
    allGrads = [allGrads grads]; 
end


% C1 correlation with analytic signals
if imposeParams.modC1Analytic ... % mod_C1
    && ~isempty(modC1BandsToUse),

    % get modulation bands for select subbands
    corrMods = modBands(:, modC1BandsToUse, :);
    corrMods2 = modBandsFiltered(:, modC1BandsToUse, :);
    
    [errors, grads] = getC1AnalyticErrorAndGradients( currentSubband, stats, ...
        modSubbands, modSubbands2, corrMods, corrMods2, modC1BandsToUse );
    
    allErrors = [allErrors errors'];
    allGrads = [allGrads grads]; 
end


% C2 amplitude correlation
if imposeParams.modC2Amp,
    
    [errors, grads] = getC2AmpErrorAndGradients( currentSubband, stats, ...
        modSubbands, modSubbands2, modFilter, c2AmpOffsets );
    
    % add errors/gradients to array
    allErrors = [allErrors errors'];
    allGrads = [allGrads grads]; 
end


% C2 correlation
if imposeParams.modC2, % mod_C2
    
    % get modulation bands
    modFilter = filters.modC2Filters;
    modSubbands = generateSubbands( currentSubbandEnv, modFilter );
    modSubbands2 = applyFilterParallel( squeeze(modSubbands), modFilter ); % b_s,m * h_m
    
    [errors, grads] = getC2ErrorAndGradients( currentSubband, stats, ...
        modSubbands, modSubbands2, modFilter );
    
    % add errors/gradients to array
    allErrors = [allErrors errors'];
    allGrads = [allGrads grads]; 
end

% % diplay array size
% disp('All Errors');
% size(allErrors)
% disp('All Gradients');
% size(allGrads)


%
% 2. Calculate total cost and gradient from errors
%
nFrames = length(currentSubbandEnv);
cost = sum(allErrors.^2); % least squares
grad = -2 * sum( (ones(nFrames, 1) * allErrors) .* allGrads, 2 ); % nFrames



% ------------------------
% Error/Gradient Functions
% ------------------------

%
% Calculates the error and gradients for the modulation power
%
function [errors, grads] = getModPowerErrorAndGradients( currentSubband, stats, ...
    modSubbands, modSubbands2, moments )
    
nModbands = size(modSubbands, 2);

values = calculateModPowerStats( modSubbands, moments );
errors = stats.modPower(currentSubband, :) - values;

grads = [];
for iModband = 1:nModbands,

    mod = modSubbands(:, iModband);
    mod2 = modSubbands2(:, iModband);

    grad = calculateModPowerGrads( mod, mod2, moments );

    grads = [grads grad];
end
    
    
%
% Calculates the error and gradients for the C1 correlations
%
function [errors, grads] = getC1ErrorAndGradients( currentSubband, stats, ...
    modSubbands, modSubbands2, corrMods, corrMods2, modC1BandsToUse )
    
nModbands = size(modSubbands, 2);
nCorrbands = size(corrMods, 2);

% current subband stats
values = calculateModC1Stats( modSubbands, corrMods );

% get errors and gradients
errors = [];
grads = [];
for iCorrBand = 1:nCorrbands,

    mody = corrMods(:, iCorrBand, :); % b_s',m
    mody2 = squeeze(corrMods2(:, iCorrBand, :)); % b_s',m * h_m

    for iModband = 1:nModbands,

        x = modSubbands(:, iModband);
        xx = modSubbands2(:, iModband);

        y = mody(:, iModband);
        yy = mody2(:, iModband);

        value = values(iCorrBand, iModband);
        statsValue = stats.modC1(currentSubband, ...
            modC1BandsToUse(iCorrBand), iModband);

        error = statsValue - value;
        grad = calculateModC1Grads( x, y, xx, yy, value );

        % add errors/gradients to array
        errors = [errors error];
        grads = [grads grad]; 
    end
end


%
% Calculates the error and gradients for the C1 analytic correlations
%
function [errors, grads] = getC1AnalyticErrorAndGradients( currentSubband, stats, ...
    modSubbands, modSubbands2, corrMods, corrMods2, modC1BandsToUse )

nModbands = size(modSubbands, 2);
nCorrbands = size(corrMods, 2);

% current subband stats
values = calculateModC1AnalyticStats( modSubbands, corrMods ); 

% get errors and gradients
errors = [];
grads = [];

for iCorrBand = 1:nCorrbands,
    mody = corrMods(:, iCorrBand, :); % b_r,m
    mody2 = squeeze( corrMods2(:, iCorrBand, :) ); % b_r,m * h_m 
    mody2_hat = imag( hilbert( mody2 ) );

    for iModband = 1:nModbands,
        x = modSubbands(:, iModband);
        xx = modSubbands2(:, iModband);

        y = mody(:, iModband);
        yy = mody2(:, iModband);
        yy_hat = mody2_hat(:, iModband);

        value = values(iCorrBand, iModband, :);
        statsValue = stats.modC1Analytic(currentSubband, ...
            modC1BandsToUse(iCorrBand), iModband, :);

        error = squeeze(statsValue) - squeeze(value);
        [grad_r, grad_i] = calculateModC1AnalyticGrads( x, y, xx, yy, ...
            yy_hat, value );
        grad = [grad_r grad_i];

        % add errors/gradients to array
        errors = [errors; error];
        grads = [grads grad]; 
    end
end

    
%
% Calculates the error and gradients for the C2 amplitude correlations
%
function [errors, grads] = getC2AmpErrorAndGradients( currentSubband, stats, ...
    modSubbands, modSubbands2, modFilter, c2AmpOffset )

% c2AmpOffset = 10; % only use upto 5 adjacent modbands
% TODO: read from parameter settings

[nFrames, nModbands] = size(modSubbands);
wi = 1/nFrames;

% pre-calculate
a = hilbert(modSubbands);
b_hat = imag(a);
a_amp = abs(a);


errors = [];
grads = [];
for m = 1:nModbands-1,

    hm = modFilter(:, m);
    bm = modSubbands(:, m);
    bm_hat = b_hat(:, m);
    
    hbm = modSubbands2(:, m); % hm * bm
    am_amp = a_amp(:, m);
    sig_m = sqrt(wi * sum( bm.^2 )); % assumes filters are bandpass, so zero-mean

    
    for n = (m+1):min( nModbands, m+c2AmpOffset ),

        hn = modFilter(:, n);
        bn = modSubbands(:, n);
        bn_hat = b_hat(:, n);
        
        hbn = modSubbands2(:, n); % hn * bn
        an_amp = a_amp(:, n);
        sig_n = sqrt(wi * sum( bn.^2 )); % assumes filters are bandpass, so zero-mean

        value = calculateModC2AmpStats( am_amp, an_amp, sig_m, sig_n );
        error = stats.modC2Amp(currentSubband, m, n) - value;

        grad = calculateModC2AmpGrads( bm, bn, hm, hn, ...
            bm_hat, bn_hat, am_amp, an_amp, sig_m, sig_n, hbm, hbn, ...
            value );

        errors = [errors; error];
        grads = [grads grad];
    end
end


%
% Calculates the error and gradients for the C2 correlations
%
function [errors, grads] = getC2ErrorAndGradients( currentSubband, stats, ...
    modSubbands, modSubbands2, modFilter )

nModbands = size(modSubbands, 2);

% current subband stats
values = calculateModC2Stats( modSubbands );

% get errors and gradients
errors = squeeze(stats.modC2(currentSubband, :, :)) - values;
errors = errors(:); % make single column;

grads_r = [];
grads_i = [];
for iModband = 1:(nModbands - 1),
    [grad_r, grad_i] = calculateModC2Grads( modSubbands(:, iModband:(iModband+1)) , ...
        modFilter(:, iModband:(iModband+1)), modSubbands2(:, iModband:(iModband+1)) );

    grads_r = [grads_r grad_r];
    grads_i = [grads_i grad_i];
end
grads = [grads_r grads_i];
