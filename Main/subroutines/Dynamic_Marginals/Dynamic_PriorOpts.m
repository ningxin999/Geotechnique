function [PriorOpts, myPriorDist] = Dynamic_PriorOpts(Prior_EoD,jj,AnParam,observationsarray,Prior_hyperdiscrep,Posterior)
% DYNAMIC_PRIOROPTS - Configures prior options for Bayesian inference
% 
% Dynamically sets priors for forward parameters and observation noise hyperparameters
% Handles both initial priors (jj=1) and inferred priors (jj>1)
% Automatically adjusts for missing observation data


%% Initialize forward model parameter priors
if jj == 1
    % Use initial experimental design priors
    PriorOpts = datainput(Prior_EoD); 
else
    % For subsequent stages, use samples from previous posterior
    for kk = 1:AnParam.N_parameters
        temp(:,kk) = Posterior{jj-1}(kk).samples;
    end
    PriorOpts.Inference.Data = temp;
    
    % Handle copula options
    if AnParam.inferredCopula == "off"
        PriorOpts.Copula.Type = 'Independent';
    end
end

%% Configure observation noise hyperparameter priors
for ii = 1: AnParam.N_outputfields
    % Only process if observation data exists for this stage
    condition0 = ~isnan(observationsarray{ii}(:,jj)); 
    if  all(condition0==true)       
        priorDiscrepancy{ii}  = datainput(Prior_hyperdiscrep{ii}); 

        % Scale hyperparameters by observation magnitude
        if ~isempty(AnParam.COVdata) ==1
            obs_magnitute = 1; % no weight for obeservation
        else
            obs_magnitute = mean(abs(observationsarray{ii}(:,jj)),"all"); % observation at jj-th stage 
            %obs_magnitute =  max(abs(observationsarray{ii}(:,jj)));% observation at jj-th stage
        end

        % Apply scaling to all hyperparameters except spatial ones (marked 'h')
        for zz = 1: length(priorDiscrepancy{ii}.Marginals)
            hyperName = {priorDiscrepancy{ii}.Marginals.Name};
            if hyperName{1,zz} == 'h' % consider the spatial effect
            priorDiscrepancy{ii}.Marginals(zz).Parameters =  priorDiscrepancy{ii}.Marginals(zz).Parameters;
            else
            priorDiscrepancy{ii}.Marginals(zz).Parameters =  priorDiscrepancy{ii}.Marginals(zz).Parameters*obs_magnitute;
            end
        end

    end
end

%% Combine forward parameters and noise hyperparameter priors
if jj == 1% initial prior
        for ii = 1: AnParam.N_outputfields
            % See whether data missing in obsevation
            condition0 = ~isnan(observationsarray{ii}(:,jj)); 
            if  all(condition0==true) 
                PriorOpts.Marginals = [PriorOpts.Marginals,priorDiscrepancy{ii}.Marginals];
            end
        end
       

else % infferred prior
        % Subsequent stages: Create placeholders for inferred parameters first 
        N_parameter = size(Prior_EoD,1); % count how many model paramters
    
        % Create placeholder structure for inferred parameters
        PriorOpts.Marginals = struct('Name',cell(1, N_parameter),'Type',cell(1, N_parameter),'Parameters', ...
                    cell(1, N_parameter));

         % Then append hyperparameters
        for qq = 1:AnParam.N_outputfields
            % See whether data missing in obsevation
            condition0 = ~isnan(observationsarray{qq}(:,jj)); 
            if  all(condition0==true)
                PriorOpts.Marginals = [PriorOpts.Marginals,priorDiscrepancy{qq}.Marginals];%merge the above two priors marginals
            end
        end
end

%% Create final prior distribution object
 myPriorDist = uq_createInput(PriorOpts);


