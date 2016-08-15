function plotModC2Stats( modC2Stats )
%
% Creates a plot for the within subband (C2) statistics
% 
set(gcf, 'name', 'C2 Statistics');

modC2 = modC2Stats(:,:,1) + 1i*modC2Stats(:,:,2);

subplot(1,2,1);
plotImage( abs(modC2) );
caxis([0 2]);
colorbar;
title('Amplitude');
xlabel('Modband #');
ylabel('Subband #');

subplot(1,2,2);
plotImage( angle(modC2)/pi );
colorbar;
caxis([-1 1]);
title('Phase');
xlabel('Modband #');
ylabel('Subband #');

colormap(diverge('rwb', 100, 2));