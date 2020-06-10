function ACF = autocorr_stat(A)
    % -------------------------------------------------------
    % Compute the statistical 2D autocorrelation of a matrix.
    % -------------------------------------------------------
    %
    % ACF = autocorr_stat(A)
    %
    % Input
    % -----
    %
    % A: Input matrix (must be 2D matrix)
    %
    % Output
    % ------
    %
    % ACF: Output 2D auto-correlation (size(ACF) = 2 * size(A) - 1)
    
    % Initialize output matrix
    ACF = zeros(2 * size(A) - 1);
    
    % Determine total number of elements in ACF to loop over.
    N = size(ACF, 1) * size(ACF, 2);
    
    % Determine position of center pixel in output matrix
    row0 = ceil(size(ACF, 1) / 2);
    col0 = ceil(size(ACF, 2) / 2);
    
    % Loop over all entries in the output matrix. Entry r has position
    % (rowr, colr) in the ACF matrix and describes the vector (drow, dcol).
    % A copy of the input matrix is displaced by (drow, dcol) with respect
    % to itself and the correlation of the overlapping areas is calculated
    % for this vector.
    for r = 1:N
        rowr = rem((r - 1), size(ACF, 1)) + 1;
        colr = (r - rowr) / size(ACF, 1) + 1;
        
        drow = rowr - row0;
        dcol = colr - col0;
        
        % Determine overlapping areas of input matrix (A1) and the
        % displaced copy (A2)
        
        A1rows = max(1, 1 + drow):min(size(A, 1), size(A, 1) + drow);
        A2rows = max(1, 1 - drow):min(size(A, 1), size(A, 1) - drow);
        
        A1cols = max(1, 1 + dcol):min(size(A, 2), size(A, 2) + dcol);
        A2cols = max(1, 1 - dcol):min(size(A, 2), size(A, 2) - dcol);

        A1 = A(A1rows, A1cols);
        A2 = A(A2rows, A2cols);

        Nr = size(A1, 1) * size(A1, 2);     % Number of pixels in overlapping area
        I1 = mean(A1, 'all');               % Mean intensity of A1
        I2 = mean(A2, 'all');               % Mean intensity of A2
        s1 = std(A1, 1, 'all');             % Standard deviation of A1
        s2 = std(A2, 1, 'all');             % Standard deviation of A2

        % Calculate the Pearson correlation coefficient for the overlapping
        % areas
        ACF(rowr, colr) = (1 / (Nr * s1 * s2)) * sum((A1 - I1) .* (A2 - I2), 'all');
    
    end
end
