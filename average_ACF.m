function [ACFr, R] = average_ACF(A, angles, radii)
    % Average the autocorrelation matrix A over different angles. angles
    % and radii variables are of the shape [start, stop, step]
    
    % Define default values of angles and radii if none are given
    if nargin == 1
        ANG = 0:0.1:359.9;
        R   = 0:0.1:(floor(min(size(A)) / 2) - 1);
        
    elseif nargin == 2
        ANG = angles(1):angles(3):angles(2);
        R   = 0:0.1:(floor(min(size(A)) / 2) - 1);
        
    elseif nargin == 3
        ANG = angles(1):angles(3):angles(2);
        R   = radii(1):radii(3):radii(2);
    end
    
    % Define center pixel of autocorrelation matrix
    x0 = ceil((size(A, 1) + 1) / 2);
    y0 = ceil((size(A, 2) + 1) / 2);

    % Initialize output array
    ACFr = zeros(1, length(R));
    
    % Loop over all angles and radii from the origin (center pixel of
    % autocorrelation matrix) and average over the angle
    for n = 1:length(R)
        r = R(n);
        for ang = ANG
            x = x0 + r * cosd(ang);
            y = y0 + r * sind(ang);

            i = round(x);
            j = round(y);

            ACFr(n) = ACFr(n) + (A(i, j) / length(ANG));
        end
    end
end