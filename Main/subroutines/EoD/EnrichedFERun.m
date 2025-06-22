function EnrichedFERun(myUQLinkModel,Prior_EoD,AnParam,filename,jj, varargin)

% EnrichedFERun: Enrich the sampling process for Sobol and run FE models.
%   This function enriches the design of experiments (EoD) using Sobol sampling,
%   evaluates the finite element (FE) models, and extracts/saves results.
%
% Inputs:
%   - myUQLinkModel: Structure combining FE packages and UQLab.
%   - Prior_EoD: Probabilistic input for surrogate enriching.
%   - AnParam: Structure containing analysis parameters.
%   - filename: Filename for FE result extraction (e.g., 'NonlinearTruss').
%   - jj: Current stage index.
%   - varargin: Optional additional arguments (e.g., Posterior).
%
% Note:
%   This function handles two scenarios:
%   1. Initial enrichment stage (no posterior).
%   2. Subsequent stages with posterior information.

% Extract Posterior if provided
Posterior = [];
if ~isempty(varargin)
    Posterior = varargin{1};
end

% get the working directory
directory = AnParam.directory;

% enriching EDarray, Run and extract the FE results
if jj == AnParam.N_enrich
    if isempty(Posterior) 
        % case one: initial sampling
        EDarray = Enrich_sampling(Prior_EoD,AnParam);
    else  
        % case two: Enriched sampling
        EDarray = Enrich_sampling(Prior_EoD,AnParam,jj,Posterior);
    end
    %[~] = uq_evalModel(myUQLinkModel,EDarray);
    extract_FEresult(filename,directory,AnParam,EDarray); 

end


end