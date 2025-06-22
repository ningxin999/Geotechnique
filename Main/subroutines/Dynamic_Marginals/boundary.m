function myPriorDist = boundary(PriorOpts,boundary_prior,AnParam,myPriorDist)
% BOUNDARY Apply parameter boundaries to prior distribution
%
% This function adds boundaries to prior distributions to prevent unrealistic values
% (e.g., negative values for parameters that must be positive)
%
% Inputs:
%   PriorOpts       - Options structure for prior distribution
%   boundary_prior  - Structure containing boundary values for each parameter
%   AnParam         - Analysis parameters structure
%   myPriorDist     - Original prior distribution without boundaries
%
% Output:
%   myPriorDist     - Prior distribution with applied boundaries (if enabled)


% Only proceed if boundary setting is enabled
if AnParam.Switch_priorBound == "on"
     % Apply boundaries to each parameter
    for ii = 1:AnParam.N_parameters
        PriorOpts.Marginals(ii).Bounds = [...
            boundary_prior(ii).parameter1, ...
            boundary_prior(ii).parameter2];
    end

    % create new prior with boudary
    myPriorDist = uq_createInput(PriorOpts);
end


