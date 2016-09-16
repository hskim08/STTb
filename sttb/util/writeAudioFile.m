function writeAudioFile(x, fs, filename)
%
% Write audio to file with the matching write audio function.
% This code will automatically choose between audiowrite and wavwrite based
% on the Matlab version.
%
% 
%   Author(s): H.S. Kim, 9-15-16

if str2double(strtok(version(), '.')) > 7,    
    audiowrite(filename, x, fs);
else
    wavwrite(x, fs, filename); %#ok<DWVWR>
end