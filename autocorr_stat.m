function B = autocorr_stat(A)
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
    
    % Determine total number of elements in A to loop over.
    N = size(A, 1) * size(A, 2);
    
    % Initialize intermediate results
    Nr      = zeros(2 * size(A) - 1);
    I1sum   = zeros(2 * size(A) - 1);
    I2sum   = zeros(2 * size(A) - 1);
    I1sqsum = zeros(2 * size(A) - 1);
    I2sqsum = zeros(2 * size(A) - 1);
    
    % Determine position of center pixel in output matrix
    row0 = ceil(size(Nr, 1) / 2);
    col0 = ceil(size(Nr, 2) / 2);
    
    % Loop over all elements in input matrix to determine average intensity
    % and variance of pixel intensity.
    for n = 1:N
        row1 = rem((n - 1), size(A, 1)) + 1;
        col1 = (n - row1) / size(A, 1) + 1;
        
        for m = 1:N
            row2 = rem((m - 1), size(A, 1)) + 1;
            col2 = (m - row2) / size(A, 1) + 1;
            
            
            drow = row2 - row1;
            dcol = col2 - col1;
            
            i = row0 + drow;
            j = col0 + dcol;
            
            Nr(i, j)        = Nr(i, j) + 1;
            I1sum(i, j)     = I1sum(i, j) + A(n);
            I2sum(i, j)     = I2sum(i, j) + A(m);
            I1sqsum(i, j)   = I1sqsum(i, j) + (A(n))^2;
            I2sqsum(i, j)   = I2sqsum(i, j) + (A(m))^2;
        end
    end
    
    % Calculations intermediate results
    I1avg = I1sum ./ Nr;
    I2avg = I2sum ./ Nr;
    
    var1 = (I1sqsum ./ Nr) - I1avg.^2;
    var2 = (I2sqsum ./ Nr) - I2avg.^2;
    
    % Initialize output matrix
    B = zeros(2 * size(A) - 1);
    
    % Loop over all elements in input matrix to determine the
    % autocorrelation
    for n = 1:N
        row1 = rem((n - 1), size(A, 1)) + 1;
        col1 = (n - row1) / size(A, 1) + 1;
        
        for m = 1:N
            row2 = rem((m - 1), size(A, 1)) + 1;
            col2 = (m - row2) / size(A, 1) + 1;
            
            drow = row2 - row1;
            dcol = col2 - col1;
            
            i = row0 + drow;
            j = col0 + dcol;
            
            B(i, j) = B(i, j) + ...
                ((A(n) - I1avg(i, j)) * (A(m) - I2avg(i, j))) / ...
                (sqrt(var1(i, j)) * sqrt(var2(i, j)) * Nr(i, j));
            
        end
    end
end
