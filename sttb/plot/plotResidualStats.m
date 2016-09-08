function plotResidualStats( residualStats, sampleRate, residuals )
%
% Creates a plot that shows the residual stats with the residual.
%

a = residualStats.coeffs;

if ~exist('sampleRate', 'var'),
    sampleRate = 1;
    xlabelText = 'Normalized Frequency';
else
    xlabelText = 'Frequency (Hz)';
end

if exist('residuals', 'var'),
    
    nSamples = length(residuals);
    nWelch = round(nSamples/8);
    
    % Get the PSD estimate using Welch's Method
    psd = 10*log10( pwelch( residuals, nWelch, [], nWelch ) );
    nFreqs = length(psd);
    
    f = (0:nFreqs-1)/nFreqs * sampleRate/2;
    
    % Get the AR estimate
    arModel = 20*log10( abs( freqz( 1, a, nFreqs )' ) );

    plot(f, [psd-mean(psd) (arModel-mean(arModel))']);
    legend('PSD', 'AR Model');
else
    nFreqs = 1000;
    f = (0:nFreqs-1)/nFreqs * sampleRate/2;
    
    % Get the AR estimate
    arModel = 20*log10( abs( freqz( 1, a, nFreqs )' ) );

    plot(f, (arModel-mean(arModel))');
end

set(gcf, 'name', 'Residual Model');
axis tight;

xlabel(xlabelText);
ylabel('Relative Power (dB)');