function fullFilter = generateFullFilter( filts, signalLength )
%generateFullFilter     Generates the fullband filter
%
% Parameters:
% filts - The half band filters. This can be a filterbank. Expects the
% filters to be real in the frequency domain.
% signalLength - The length of the signal.
%
% Returns:
% fullFilter - The fullband signal. 
%
% Expands the positive half filter by generating the negative frequencies.
%

filterLength = size(filts, 1);

if rem( signalLength, 2 ) == 0, % even length
    fullFilter = [filts' fliplr( filts(2:filterLength-1, :)' )]'; % generate negative frequencies in right place; filters are column vectors
else % odd length
    fullFilter = [filts' fliplr( filts(2:filterLength, :)' )]';
end