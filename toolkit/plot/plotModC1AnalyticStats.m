function plotModC1AnalyticStats( modC1AnalyticStats, isAmp, centerFreqs )
%
% Creates a plot for the between band (C1) analytic statistics
%
c1Complex = modC1AnalyticStats(:,:,:,1) + 1i*modC1AnalyticStats(:,:,:,2);

nModbands = size(modC1AnalyticStats, 3);

% plot
nRows = 5;
nCols = 4;
if isAmp, % amplitude plot
    c1Amp = abs(c1Complex);
    
    set(gcf, 'name', 'C1 Statistics Amp.');
    
    for iModband = 1:nModbands,
        subplot(5, 4, iModband);
        
        plotImage( c1Amp(:, :, iModband) );
        caxis([0 2]);
        axis square;

        % subplot title
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
    
else % phase plot
    c1Phase = angle(c1Complex)/pi;
    
    set(gcf, 'name', 'C1 Statistics Phase');
    
    for iModband = 1:nModbands,
        subplot(5, 4, iModband);
        
        plotImage( c1Phase(:, :, iModband) );
        caxis([-1 1]);
        axis square;

        % subplot title
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
end

colormap(diverge('rwb', 100, 2));