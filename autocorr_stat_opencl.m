function ACF = autocorr_stat_opencl(A, device_num)
    
    % Add path with functions for OpenCL implementation
    [folder, ~, ~] = fileparts(which('autocorr_stat_opencl'));
    addpath(fullfile(folder, 'MatCL-master'));
    
    if size(A,1) ~= size(A,2)
        error('Input matrix needs to be square.')
    end
    
    % Get maximum workgroup size from device data
    [~, ~, ~, max_wg_size, ~, ~] = cl_get_devices;
    
    N = int32(size(A, 1));

    % Reshape input matrix to 1D array
    A = reshape(A, [], 1);

    % The optimum value for the local range is the maximum size of one
    % workgroup. If the input matrix is smaller than the optimum size, the
    % local range is set to the width of the matrix. If the matrix is
    % larger, the local range is set to the optimum value. This currently
    % only supports sizes of multiples of opt_local_range.
    
    opt_local_range = int32(max_wg_size(device_num));

    
    if N > opt_local_range
        if rem(N, opt_local_range) == 0
            M = opt_local_range;
        else
            error('Matrix size needs to be a power of 2 if larger than maximum number of workgroups.')
        end
    else
        M = N;
    end
    
    % The number of times the local range fits into one line of the input
    % matrix.
    x = N / M;
    
    % Define build options and local/global range.
    settings = sprintf('-DN=%d -DM=%d -DX=%d', N, M, x);
    global_range = double([N, N, 1]);
    local_range = double([1, M, 1]);
    
    % Compile the OpenCL kernel
    cl_run_kernel(device_num, 'autocorr.cl', settings);

    % Initialize intermediate results
    Nr = int32(zeros((N * 2 - 1) ^ 2, 1));
    Isum = double(zeros(size(Nr)));
    Isqsum = double(zeros(size(Nr)));

    % Run kernel for the calculation of intermediate results
    cl_run_kernel(device_num, 'int_sums', ...
                                global_range, local_range, ...
                                A, Nr, Isum, Isqsum, ...
                                [1, 0, 0, 0]);

    % Calculate average and variance
    Nrd = double(Nr);
    I1avg = Isum ./ Nrd;
    var1 = Isqsum ./ Nrd - I1avg .^2;

    % Make use of symmetries
    I2avg = flip(I1avg);
    var2 = flip(var1);

    % Initialize final result
    ACF = double(zeros(size(Nr)));

    % Run kernel for the calculation of the autocorrelation
    cl_run_kernel(device_num, 'acf', ...
                                global_range, local_range, ...
                                A, I1avg, I2avg, ACF, ...
                                [1, 1, 1, 0]);


    % Calculate final result and reshape back to square matrix
    ACF = ACF ./ (sqrt(var1) .* sqrt(var2) .* Nrd);
    ACF = reshape(ACF, 2*N - 1, []);
end
