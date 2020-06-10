% Example: How to use autocorr_stat for multiple inputs

% Add path with auto-correlation functions to the matlab searchpath. This
% allows the function to run inside the 'Examples' folder.

addpath(fullfile('.', '..'));


% Generate input matrices. As an example, a number of identical 2D sine
% functions are generated. If desired, a cell array with images can be
% loaded here as D.

N   = 50;       % Number of matrices
sz  = 128;      % Input matrix size

[X, Y]  = meshgrid(1:sz);                   % Create a grid of coordinates
Z       = sin(0.05 * X) + sin(0.05 * Y);    % Calculate 2D sine function

D = cell(N, 1);     % Initialize cell for input matrices
D(:) = {Z};         % Set all entries of D to Z


% Show image of one input matrix. To change which entry of D to show,
% change i.

i = 4;

figure
image(D{i}, 'CDataMapping', 'scaled')
colorbar
title(sprintf('Input matrix %i', i))


% Calculate the 2D auto-correlations. After the program is finished, the
% computation time of the auto-correlations will be shown in the Matlab
% command window.

C = cell(N, 1);     % Initialize output cell

tic
for n = 1:N
    C{n} = autocorr_stat(D{n});
end
toc


% Show image of one auto-correlation

figure
image(C{i}, 'CDataMapping', 'scaled')
colorbar
title(sprintf('2D auto-correlation %i', i))
