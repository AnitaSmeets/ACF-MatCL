% Example: How to use autocorr_stat

% Initialize input matrix

sz = 128;   % Input matrix size

[X, Y]  = meshgrid(1:sz);
Z       = sin(0.05 * X) + sin(0.05 * Y);    % 2D sine function

% Show image of the input matrix

figure
image(Z, 'CDataMapping', 'scaled')
colorbar
title('Input matrix')

% Calculate the 2D auto-correlation

tic
ACF = autocorr_stat(Z);
toc

% Show image of the auto-correlation

figure
image(ACF, 'CDataMapping', 'scaled')
colorbar
title('2D auto-correlation')