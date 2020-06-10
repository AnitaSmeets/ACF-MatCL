function D = autocorr_stat_par(C)
    % ----------------------------------------------
    % Parallel bulk computation of auto-correlations
    % ----------------------------------------------
    %
    % D = autocorr_stat_par(C)
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

    % Preallocate future objects
    f(1:sz) = parallel.FevalFuture;

    % Create a progressbar
    h = waitbar(0, 'Calculating...');

    % Evaluate autocorr_stat for all entries in the input cell. The
    % computations run in parallel.
    for i = 1:sz
        f(i) = parfeval(@autocorr_stat, 1, C{i});
    end

    results = cell(1, sz);

    % Fetch results from the previous loop as soon as they become available
    % and add them to results.
    for i = 1:sz
        [completedIdx, value] = fetchNext(f);
        results{completedIdx} = value;
    end

    % Update the progressbar after each iteration of the loop is finished.
    updateWaitbarFuture = afterEach(f, @(~) waitbar(sum(strcmp('finished', {f.State})) / numel(f), h), 1);
    
    % Close the progressbar after all workers have finished.
    afterAll(updateWaitbarFuture, @(h) delete(h), 0);

    D = results;
end
