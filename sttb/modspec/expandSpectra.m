function Xpand = expandSpectra( X, nFrames )
%expandSpectra    Expands a half band signal to its full band.
%
% Parameters:
% X - A halfband spectra
% nFrames - The number of frames in the time domain.
%
% Returns:
% Xpand - The fullband spectra 
%

if rem(nFrames, 2) == 0, % even
    nFreqs = size(X, 1);
    Xpand = [X; conj(flipud(X(2:nFreqs-1, :)))];
else
    nFreqs = size(X, 1);
    Xpand = [X; conj(flipud(X(2:nFreqs, :)))];
end