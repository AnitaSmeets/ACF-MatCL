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
    
    % Loop over all vectors in the output matrix to determine the value of
    % the auto-correlation for this vector
    for r = 1:N
        % Determine row and column number of vector in ACF
        rowr = rem((r - 1), size(ACF, 1)) + 1;
        colr = (r - rowr) / size(ACF, 1) + 1;
        
        % Calculate the separation vector belonging to this element in ACF
        drow = rowr - row0;
        dcol = colr - col0;
        
        % Displace copy of A over itself and determine overlapping areas
        
        A1rows = max(1, 1 + drow):min(size(A, 1), size(A, 1) + drow);
        A2rows = max(1, 1 - drow):min(size(A, 1), size(A, 1) - drow);
        
        A1cols = max(1, 1 + dcol):min(size(A, 2), size(A, 2) + dcol);
        A2cols = max(1, 1 - dcol):min(size(A, 2), size(A, 2) - dcol);

        A1 = A(A1rows, A1cols);
        A2 = A(A2rows, A2cols);

        % Calculate intermediate results
        Nr = size(A1, 1) * size(A1, 2);
        I1 = mean(A1, 'all');
        I2 = mean(A2, 'all');
        s1 = std(A1, 1, 'all');
        s2 = std(A2, 1, 'all');

        % Calculate value of ACF for this vector
        ACF(rowr, colr) = (1 / (Nr * s1 * s2)) * sum((A1 - I1) .* (A2 - I2), 'all');
    
    end
end
