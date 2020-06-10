% Example: How to use autocorr_stat_opencl for a single input

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
% computation time of the auto-correlations will be shown in the Matlab
% command window.
% To change the computation device, change device_num.
% To list all available OpenCL devices run the command cl_get_devices
% in the Matlab command window.

device_num = 1;

tic
ACF = autocorr_stat_opencl(Z, device_num);
toc


% Show image of the auto-correlation

figure
image(ACF, 'CDataMapping', 'scaled')
colorbar
title('2D auto-correlation')
