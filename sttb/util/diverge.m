function div = diverge(type, n, gamma)
%
% Returns a divergent colormap.
%
% type - 'rwb', 'ryb', 'owp', 'rwk', 'band#'
% n - number of steps for the color map. default depends on the palette.
% gamma - a gamma curve value for the color map. default 1.7
%
% Usage:
%   colormap(diverge('rwb'));
%   colormap(diverge('rwb', 100));
%   colormap(diverge('rwb', 100, 1.7));
% 
%   Author(s): H.S. Kim, 9-15-16

if ~exist('type', 'var') || isempty(type),
    type = 'rwb';
end

% get a palette
div = getPalette(type);

if ~exist('n', 'var'), % n not specified, return default
    div = div/255;
    return;
end

% fit length
nCurrent = size(div, 1);
padding = floor(n/nCurrent);

r = resample(div(:, 1), n+padding, nCurrent);
g = resample(div(:, 2), n+padding, nCurrent);
b = resample(div(:, 3), n+padding, nCurrent);

div = [r g b]/255.0;

div = div(1:end-padding, :);

% limit values
div(div < 0) = 0; 
div(div > 1) = 1;


% adjust gamma curve
if ~exist('gamma', 'var'),
    gamma = 1.7;
end
div = div .^ gamma;


%
% Returns a palette.
%
% Palettes from http://colorbrewer2.org
%
function div = getPalette(type)
% TODO: add more palettes

% -------
% 1-color
% -------

grays = [...
    255,255,255 % grays
    240,240,240
    217,217,217
    189,189,189
    150,150,150
    115,115,115
    82,82,82
    37,37,37
    0,0,0
    ];

purples = [...
    252,251,253 % purples
    239,237,245
    218,218,235
    188,189,220
    158,154,200
    128,125,186
    106,81,163
    84,39,143
    63,0,125
    ];

greens = [...
    247,252,245 % greens
    229,245,224
    199,233,192
    161,217,155
    116,196,118
    65,171,93
    35,139,69
    0,109,44
    0,68,27
    ];

oranges = [...
    255,245,235 % oranges
    254,230,206
    253,208,162
    253,174,107
    253,141,60
    241,105,19
    217,72,1
    166,54,3
    127,39,4
    ];

blues = [...
    247,251,255 % blues
    222,235,247
    198,219,239
    158,202,225
    107,174,214
    66,146,198
    33,113,181
    8,81,156
    8,48,107
    ];

reds = [...
    255,245,240 % reds
    254,224,210
    252,187,161
    252,146,114
    251,106,74
    239,59,44
    203,24,29
    165,15,21
    103,0,13
    ]; 

% -------
% 3-color
% -------

% Red - White - Blue
rwb = [ ...
    103,0,31
    178,24,43
    214,96,77
    244,165,130
    253,219,199
    247,247,247
    209,229,240
    146,197,222
    67,147,195
    33,102,172
    5,48,97 ...
    ];
rwb = flipud(rwb);

% Red - White - Black
rwk = [...
    103,0,31
    178,24,43
    214,96,77
    244,165,130
    253,219,199
    255,255,255
    224,224,224
    186,186,186
    135,135,135
    77,77,77
    26,26,26
    ];
rwk = flipud(rwk);

% Red - Yellow - Blue
ryb = [ ...
    94    79   162
    50   136   189
   102   194   165
   171   221   164
   230   245   152
   255   255   191
   254   224   139
   253   174    97
   244   109    67
   213    62    79
   158     1    66  ];

% Orange - White - Purple
owp = [...
    127,59,8
    179,88,6
    224,130,20
    253,184,99
    254,224,182
    247,247,247
    216,218,235
    178,171,210
    128,115,172
    84,39,136
    45,0,75 ...
    ];
owp = flipud(owp);

% Color bands
if length(type) >= 4 ...
        &&strcmp(type(1:4), 'band'), % banding palette
    if length(type) < 5, 
        nDiv = 1;
    else
        nDiv = str2double(type(5));
    end
    
    % limit
    nDiv = max( min(nDiv, 6), 1); 
    
    div = [... 
        grays
        purples
        greens
        oranges
        blues
        reds
        ];
    div = flipud(div);
    div = div(1:(9*nDiv), :);
    
    return;
else
    if ~exist(type, 'var'), % palette does not exist
        warning(['Invalid palette type: ' type '. Defaulting to rwb']);
        type = 'rwb';
    end

    div = eval(type);
end