% Example: How to use average_ACF

% Add path with auto-correlation functions to the matlab searchpath. This
% allows the function to run inside the 'Examples' folder.

addpath(fullfile('.', '..'));


% Generate input matrix. As an example, a 2D gaussian centered on the
% center pixel is generated. In practice the input would be the output of 
% one of an auto-correlation function. If desired, a pre-calculated
% auto-correlation can be loaded here instead of Z.

sz = 255;   % Input matrix size

x0 = (sz + 1) / 2;  % Find the center pixel of the auto-correlation. 
                    % This pixel corresponds to r = 0.
s  = sz;            % Standard deviation for example gaussian function

[X, Y]  = meshgrid(1:sz);       % Create grid of coordinates
Z       = exp(-(X - x0).^2 ./ (2 * s)) .* exp(-(Y - x0).^2 ./ (2 * s));


% Show image of the input matrix

figure
image(Z, 'CDataMapping', 'scaled')
colorbar
title('Input matrix')


% Calculate radially averaged auto-correlation over all angles up to the
% width of the image. The averaging will not take into account the corners
% of the input image.

[ACFr1, R1] = average_ACF(Z);


% Plot results

figure
plot(R1, ACFr1)
xlabel('R (px)')
ylabel('ACF(r)')
title('All angles, all radii')


% Calculate radially averaged auto-correlation over certain angles up to
% the width of the image. To change the angles over which to average,
% change angles.

angles = 0:1:90;

[ACFr2, R2] = average_ACF(Z, angles);


% Plot results

figure
plot(R2, ACFr2)
xlabel('R (px)')
ylabel('ACF(r)')
title('Some angles, all radii')


% Calculate radially averaged auto-correlation over certain angles and
% certain radii. To change the angles over which to average, change
% angles. To change the radii change radii.

angles = 0:1:90;
radii = ((sz + 1) / 20):0.1:((sz +1) / 4);

[ACFr3, R3] = average_ACF(Z, angles, radii);


% Plot results

figure
plot(R3, ACFr3)
xlabel('R (px)')
ylabel('ACF(r)')
title('Some angles, some radii')

