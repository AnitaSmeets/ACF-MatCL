function D = bulk_ACF(C)
    % Evaluates a cell array of conductance maps using the autocorr_stat
    % function. The function is called using the parallel computing
    % toolbox. To optimize performance, configure the toolbox to use all
    % available threads on the CPU.
    
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