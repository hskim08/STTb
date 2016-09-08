function Xpand = expandSpectra( X, nFrames )
%
% Expands a half band signal to its full band
%

if rem(nFrames, 2) == 0, % even
    nFreqs = size(X, 1);
    Xpand = [X; conj(flipud(X(2:nFreqs-1, :)))];
else
    nFreqs = size(X, 1);
    Xpand = [X; conj(flipud(X(2:nFreqs, :)))];
end