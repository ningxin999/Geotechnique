function myLogLikeli_joined = likeliSwitch(jj,observationsarray,PCA,myPCE,AnParam,Prior_hyperdiscrep,coord)
% LIKELISWITCH Combine likelihood terms from different output field sources
%   Combines all likelihood terms into a single log-likelihood function,
%   handling cases where some observations may be empty.
%
% Inputs:
%   jj                  - Stage number (1 to AnParam.N_FE_stage)
%   observationsarray   - Array of observation data
%   PCA                 - PCA structure
%   myPCE               - PCE structure
%   AnParam             - Analysis parameters structure
%   Prior_hyperdiscrep  - Experimental design for observation error discrepancy
%   coord               - Spatial coordinates
%
% Output:
%   myLogLikeli_joined  - Combined log-likelihood function handle

% Initialize output and count hyperparameters
myLogLikeli_joined = '@(params,y) 0';
N_hyper_list = arrayfun(@(x) size(Prior_hyperdiscrep{x}, 1), 1:AnParam.N_outputfields);

% for loop to concatenate the myLogLikeli_joined    
% Initialize counters and storage
offset_counter = 0;      % Counts non-empty output field observations
N_start = 0;             % Starting index for hyperparameters
N_end = 0;               % Ending index for hyperparameters


% Process each output field
for ii = 1:AnParam.N_outputfields      
    %tell ii-th the observation in jj-th stage is empty or not
    has_observation = ~isnan(observationsarray{ii}(:, jj));
        
    % read the cov observation noise/model error/surrogate error if it exists
    if ~isempty(AnParam.COVdata), covdata{ii} = AnParam.COVdata{ii}{jj}; else, covdata{ii} = 'Null'; end
    if ~isempty(AnParam.surrogateerror), SE{ii} = AnParam.surrogateerror{ii}{jj}; else, SE{ii} = 0; end
    if ~isempty(AnParam.w_LL), wLL{ii} = AnParam.w_LL{ii}{jj}; else, wLL{ii} = 1; end

    if has_observation 
        offset_counter = offset_counter+1;

        % Update hyperparameter indices
        N_start = N_end + 1;
        N_end = N_start + N_hyper_list(ii) -1;


        % Create likelihood term for this output field
        myLogLikeli{ii} = sprintf('LL(params, y{%d}, PCA{%d}, myPCE{%d}, AnParam.N_parameters, %d, %d, coord{%d}, AnParam, covdata{%d}, SE{%d}, wLL{%d})', ...
                                  ii, ii, ii, N_start, N_end, ii, ii,  ii, ii);
    else
        %if ii-th the observation in jj-th stage is empty, the likelihood should not exist 
        myLogLikeli{ii} = '0';
    end

     % Append to combined likelihood string
    myLogLikeli_joined = [myLogLikeli_joined '+' myLogLikeli{ii}];
end

% Convert string to function handle
myLogLikeli_joined = eval(myLogLikeli_joined);
end

