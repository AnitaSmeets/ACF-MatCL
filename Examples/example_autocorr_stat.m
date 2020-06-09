% Example: How to use autocorr_stat

% Add path with auto-correlation functions to the matlab searchpath. This
% allows the function to run inside the 'Examples' folder.

addpath(fullfile('.', '..'));


% Generate input matrix. As an example, a 2D sine function is generated.
% If desired, an image can be loaded here instead as Z.

sz = 128;   % Input matrix size

[X, Y]  = meshgrid(1:sz);                   % Create a grid of coordinates
Z       = sin(0.05 * X) + sin(0.05 * Y);    % Calculate 2D sine function


% Show image of the input matrix

figure
image(Z, 'CDataMapping', 'scaled')
colorbar
title('Input matrix')


% Calculate the 2D auto-correlation. After the program is finished, the
% computation time of the auto-correlation will be shown in the Matlab
% command window.

tic
ACF = autocorr_stat(Z);
toc


% Show image of the auto-correlation

figure
image(ACF, 'CDataMapping', 'scaled')
colorbar
title('2D auto-correlation')