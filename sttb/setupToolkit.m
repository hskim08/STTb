function setupToolkit( verbose )
%setupToolkit   Set paths for the toolkit.
%
% setupToolkit() adds the paths needed to use the toolbox. The verbose
% level is set to 1 by default.
% 
% setupToolkit( verbose ) adds the paths needed and displays the results
% depending on the verbosity level. A verbose value of 0 will not show any
% messages. Setting verbose to 1 will display the paths that were added.
%  

if ~exist('verbose', 'var'),
    verbose = 1;
end

% seed random functions
% rng('shuffle');
% rng('default'); % reset random generator for debugging purposes

% get the path to the toolkt folder
toolkitPath = fileparts( mfilename('fullpath') );

% add all sub-folders
p = genpath(toolkitPath);
addpath( p );

% print message of paths added
if verbose,
    pathList = parseGenpath(p);
    disp([num2str(length(pathList)) ' folders added to path:']);
    for i = 1:length(pathList),
        disp(['    ' pathList{i}]);
    end
end


%
% Parse directories in genpath results.
%
function pathList = parseGenpath(p)

d = strfind(p, ':');

c = 1;
pathList = cell(length(d), 1);
for i = 1:length(d),
    pathList{i} = p(c:(d(i)-1));
    c = d(i)+1;
end
