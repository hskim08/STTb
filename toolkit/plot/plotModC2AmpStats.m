function plotModC2AmpStats( modC2AmpStats )

nSubbands = size( modC2AmpStats, 1 );

set(gcf, 'name', 'C2 Amplitude Correlation');

for iSubband = 1:nSubbands,
    subplot(4, 8, iSubband);
    plotImage( squeeze(modC2AmpStats(iSubband, :, :)) );
    axis square;
    title(['Subband: ' num2str(iSubband)]);
    caxis([1 2]);
end

colormap(diverge('rwb', 100, 2));