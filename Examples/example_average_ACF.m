% Example: How to use average_ACF

% Initialize input matrix, in practice this matrix would be the output of one of
% the auto-correlation functions

sz = 255;   % Input matrix size

x0 = (sz + 1) / 2;  % Define the center pixel
s  = sz;            % Standard deviation for gaussian function

% Initialize matrix with a gaussian centered at the center pixel

[X, Y]  = meshgrid(1:sz);
Z       = exp(-(X - x0).^2 ./ (2 * s)) .* exp(-(Y - x0).^2 ./ (2 * s));

% Show image of the input matrix

figure
image(Z, 'CDataMapping', 'scaled')
colorbar
title('Input matrix')

% Calculate radially averaged auto-correlation over all angles up to the
% width of the image

[ACFr1, R1] = average_ACF(Z);

% Show plot

figure
plot(R1, ACFr1)
xlabel('R (px)')
ylabel('ACF(r)')
title('All angles, all radii')

% Calculate radially averaged auto-correlation over certain angles up to
% the width of the image

angles = 0:1:90;

[ACFr2, R2] = average_ACF(Z, angles);

% Show plot

figure
plot(R2, ACFr2)
xlabel('R (px)')
ylabel('ACF(r)')
title('Some angles, all radii')

% Calculate radially averaged auto-correlation over certain angles and
% certain radii

angles = 0:1:90;
radii = ((sz + 1) / 20):0.1:((sz +1) / 4);

[ACFr3, R3] = average_ACF(Z, angles, radii);

% Show plot

figure
plot(R3, ACFr3)
xlabel('R (px)')
ylabel('ACF(r)')
title('Some angles, some radii')

