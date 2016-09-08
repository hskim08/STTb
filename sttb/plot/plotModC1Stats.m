function plotModC1Stats( modC1Stats, centerFreqs )
%
% Creates a plot for the between subband (C1) statistics
% 

nModbands = size(modC1Stats, 3);

set(gcf, 'name', 'C1 Statistics');
nRows = 4;
nCols = 5;
for iModband = 1:nModbands,
    subplot(nRows, nCols, iModband);
    
    plotImage( modC1Stats(:, :, iModband) );
    axis square;
    caxis([-1 1]);
    
    % label center frequencies
    if exist('centerFreqs', 'var'), 
        if iModband > size(centerFreqs),
            title('Hi-Pass');
        else
            title([num2str(iModband) ': ' num2str(centerFreqs(iModband)) ' Hz']);
        end
    else
        title(['Modband ' num2str(iModband)]);
    end
    
    % add x/y labels
    if iModband == nCols+1,
        ylabel('Suband #');
    end
    
    if iModband == nCols*(nRows-1)+2,
        xlabel('Suband #');
    end
end

colormap(diverge('rwb', 100, 2));