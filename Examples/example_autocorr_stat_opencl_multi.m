% Example: How to use autocorr_stat_opencl for multiple inputs

% Initialize input matrices

N   = 50;       % Number of matrices
sz  = 128;      % Input matrix size


[X, Y]  = meshgrid(1:sz);
Z       = sin(0.05 * X) + sin(0.05 * Y);    % 2D sine function

D = cell(N, 1);     % Initialize cell for input matrices
D(:) = {Z};         % Set all entries of D to Z

% Show image of one input matrix
i = 4;

figure
image(D{i}, 'CDataMapping', 'scaled')
colorbar
title(sprintf('Input matrix %i', i)) 

% Calculate 2D auto-correlations on the first OpenCL device
device_num = 1;

C = cell(N, 1);     % Initialize output cell

tic
for n = 1:N
    C{n} = autocorr_stat_opencl(D{n}, device_num);
end
toc

% Show image of one auto-correlation

figure
image(C{i}, 'CDataMapping', 'scaled')
colorbar
title(sprintf('2D auto-correlation %i', i))