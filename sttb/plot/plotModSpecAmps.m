function plotModSpecAmps( modSpectraAmps, env_sr )
%
% Plots the modulation spectra amplitudes
%

[nMods, nSubbands] = size(modSpectraAmps);

if exist('env_sr', 'var'),
    f = (0:nMods-1)/(nMods-1) * env_sr/2;
    xLabelText = 'Modulation Frequency (Hz)';
else
    f = (0:nMods-1)/(nMods-1) * 1/2;
    xLabelText = 'Modulation Frequency (Normalized)';
end

plotImage(f, 1:nSubbands, 20*log10(modSpectraAmps') );
xlabel(xLabelText);
ylabel('Subband #');

colormap(diverge('rwb', 100, 2));
