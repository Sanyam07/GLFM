function params = init_default_params(data, params)
    % Function to initialize or complete params structure with all
    % simulation parameters and hyperparameters for the GLFM
    % data is an input parameter in order to be able to initialize
    % params with data-based values

    if ~isfield(params,'missing'), params.missing = -1; end % value for missings
    if ~isfield(params,'alpha'), params.alpha = 1; end % Concentration parameter for the IBP
    if ~isfield(params,'bias'), params.bias = 0; end % number of latent features that should not be sampled
    if ~isfield(params,'s2Y'), params.s2Y = 0.5; end % Variance of the Gaussian prior on the auxiliary variables (pseudoo-observations) Y
    if ~isfield(params,'s2u'), params.s2u = 0.01; end % variance of auxiliary noise
    if ~isfield(params,'s2B'), params.s2B = 1; end % Variance of the Gaussian prior of the weigting matrices B
    if ~isfield(params,'Niter'), params.Niter = 1000; end % number of iterations to run
    if ~isfield(params,'maxK'), params.maxK = size(data.X,2); end % max number of latent features for memory allocation inside C++ routine
    if ~isfield(params,'verbose'), params.verbose = 1; end % plot info in command line
    if ~isfield(params,'save'), params.save = 0; end % if =1, save results

    % parameters for optional external transformation
    if ~isfield(params,'t'), params.t = cell(1,size(data.X,2) ); end % eventual external transform of obs. X = params.t{d}(Xraw)
    if ~isfield(params,'t_1'), params.t = cell(1,size(data.X,2) ); end % inverse transform
    if ~isfield(params,'dt_1'), params.t = cell(1,size(data.X,2) ); end % derivative of the inverse transform
    if ~isfield(params,'func'), params.func = 1*ones(1,size(Xmiss,2)); end % type of internal transformation for positive real-valued data
