function plotImage(varargin)
% 
% Custom image plotting function that sets the y-azis such that the upward
% direction is positive. I became weary of copying 
% set(gca, 'ydir', 'normal'))
% 

imagesc(varargin{:});
set(gca, 'ydir', 'normal');