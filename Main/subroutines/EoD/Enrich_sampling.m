function EDarray = Enrich_sampling(Prior_EoD,AnParam,jj,Posterior)
% Addme: ENRICH_SAMPLING: Enrich the design of experiments (EoD) for FE models.
% 
% This function enriches the EoD using LHS or Sobol sampling depending on
% whether posterior results from the previous stage are available.
%
% Inputs:
%   - Prior_EoD: Prior distribution for surrogate model enrichment.
%   - AnParam: Struct containing analysis parameters.
%   - jj: Current stage index.
%   - Posterior: (Optional) Posterior results from the previous stage.
%
% Outputs:
%   - EDarray: Enriched design of experiments (EoD) array.



% Define the subfolder path for saving/loading .mat data
subfolder =  fullfile(AnParam.directory.exportmat,'EoD_FE_summary');    
files = dir(fullfile(subfolder, '*.mat'));

% Step 1: Create the input distribution
PriorOpts_EoD = datainput(Prior_EoD);
myPriorDist_ED = uq_createInput(PriorOpts_EoD);

% Step 2: Load previous FE results (if any)
ED_previous = loadPreviousFEData(files,subfolder);

% Step 3: Perform sampling based on the presence of Posterior
if nargin == 2
    % Initial stage: Use LHS sampling
    if isempty(files)
        % no existed FE results before
        uq_selectInput(myPriorDist_ED)%select input prior
        EDarray = uq_getSample(AnParam.N_RUN_EoD,'LHS');

    else        
        %existed FE results, forloop to vertcat FE results and EoD array    
        EDarray = uq_LHSify(ED_previous,AnParam.N_RUN_EoD,myPriorDist_ED);
    end
else
    % Enrichment stage: Use Sobol sampling
    for ii = 1:AnParam.N_parameters  
        PriorOpts_EoD.Marginals(ii).Bounds = [Posterior{jj-1}(ii).LB Posterior{jj-1}(ii).UB];
    end
    myPriorDist_ED = uq_createInput(PriorOpts_EoD);       
    EDarray = uq_enrichSobol(ED_previous,AnParam.N_RUN_EoD,myPriorDist_ED);
end

end

function ED_previous = loadPreviousFEData(files,subfolder)
% LOADPREVIOUSFEDATA: Load and merge previous FE results.
    ED_previous = [];

    % Check if files exist
    if isempty(files)
        warning('No FE result files found in subfolder: %s. Returning empty array.', subfolder);
        return;
    end

    % loop to cancatenate
    for kk = 1:numel(files)
        data = load(fullfile(subfolder,files(kk).name));
        ED_previous = vertcat(ED_previous, data.EDarray);
    end
end