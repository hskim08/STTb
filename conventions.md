Sound Texture Toolkit (STTK) Coding Style Guide
===

The objective of the coding style guide is to make the code legible. Code should not look like a huge block of random letters. I believe well written code should have an ebb and flow that naturally visualizes the structure of the code written, even if it is Matlab code.

## Naming Convention

### Executable Script Files - lowercase under bar
Example: `analyze_sound_texture.m`


### Variables - camel case
Example: `sourceParams.filename`


### Functions - camel case
Camel case, start with a verb. Should be of the form `transformData( data, params )`.

Example: `loadSound( soundParams, analysisParams )`




## Coding Style

### One line should implement one thought
Don't pile a bunch of variable initializations in one line.


### Use linebreaks (...) when needed
Example:

~~~~
a = aFunctionWithManyParameters( alpha, beta, gamma, delta, ...
    epsilon, moreGreekLetters, omega );
~~~~

### Indentations are 4 spaces (Matlab default)
Example:

~~~~  
TODO: Fill in example
~~~~


### Space before and after function parameters
Example:

~~~~  
samples = loadSound( soundParams, analysisParams );
~~~~  

Exceptions:

* small built-in functions (Optional)
  * Example: `size(a); length(a); zeros(:, :, 10);`;

### No space before and after array access
Example:

~~~~  
value = arr(:, 10);
~~~~  

### For loop enumeration variable starts with 'i'
Example:

~~~~  
for iRow = 1:nRows,
    dataRow = data(iRow, :);
end
~~~~  

### Functions in separate files are written without an indentation.

Do not use `end` for the function. By using `end` on a function, the editor will try to add a level of indentation to every line of the file since the file is a function script. This is a waste of visual space.

Example:

~~~~
function out = addNumbers( in1, in2 )
%
% Adds numbers and returns the output
%

out = addForYou(in1, in2);

%
% Adds for the outer function because the outer function does not know how.
%
function o = addForYou(i1, i2)
o = i1 + i2;
~~~~