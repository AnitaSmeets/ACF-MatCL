function D = bulk_ACF(C)
    % ----------------------------------------------
    % Parallel bulk computation of auto-correlations
    % ----------------------------------------------
    %
    % D = bulk_ACF(C)
    %
    % Input
    % -----
    % 
    % C: Cell array containing 2D matrices to be evaluated
    %
    % Output
    % ------
    % 
    % D: Output cell array containing 2D auto-correlations
    
    
    if min(size(C)) ~= 1 || length(size(C)) > 2
        error('Input cell must be 1D')
    else
        sz = max(size(C));
    end
    
    % Initialize future objects
    f(1:sz) = parallel.FevalFuture;
    
    % Create a progressbar
    h = waitbar(0, 'Calculating...');
    
    % Evaluate autocorr_stat in parallel loops
    for i = 1:sz
        f(i) = parfeval(@autocorr_stat, 1, C{i});
    end

    results = cell(1, sz);

    % Fetch results as they become available
    for i = 1:sz
        [completedIdx, value] = fetchNext(f);
        results{completedIdx} = value;
    end

    % Update and finally close progressbar
    updateWaitbarFuture = afterEach(f, @(~) waitbar(sum(strcmp('finished', {f.State}))/numel(f), h), 1);
    closeWaitbarFuture = afterAll(updateWaitbarFuture, @(h) delete(h), 0);

    D = results;
end