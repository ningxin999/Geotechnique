function AnParam = update_AnParam(updateType, varargin)
% update_AnParam: Update the structure AnParam based on given inputs.
% 
% Inputs:
%   - updateType: 'prior' or 'obs'
%   - varargin:   Arguments depending on updateType
% 
% Cases:
%   1. 'prior': Update AnParam with prior object data.
%      Usage: AnParam = update_AnParam('prior', priorObj, AnParam);
%   2. 'obs': Update AnParam with observation-related data.
%      Usage: AnParam = update_AnParam('obs', obs_stageTime, obs_array, AnParam);

    switch lower(updateType)
        case 'prior'  % Case 1: Update from priorObj
            priorObj = varargin{1};
            AnParam  = varargin{2};

            % Update probabilistic input variables
            AnParam.Name           = priorObj.AnParam.Name;
            AnParam.N_parameters   = priorObj.AnParam.N_parameters;
            AnParam.N_outputfields = priorObj.AnParam.N_outputfields;

        case 'obs'  % Case 2: Update observation-related parameters
            obs_stageTime = varargin{1};
            obs_array     = varargin{2};
            AnParam       = varargin{3};

            % Update the number of observed loading stages
            AnParam.N_Obs_stage = size(obs_stageTime, 2);

            % Ensure directory field exists
            directory = AnParam.directory;

            % Read CSV and calculate N_Exp
            evalc('[obs_cell, obs_stageTime] = readmycsv(directory.inputcsv, true, true);');
            coordRaw = obs_cell{1}(:, 1)'; % First column as coordinates
            uniqueCoords = unique(coordRaw);
            AnParam.N_Exp = numel(coordRaw) / numel(uniqueCoords);

            % Ensure N_Exp is an integer
            mustBeInteger(AnParam.N_Exp)

            % Update number of coordinates in each output field
            AnParam.N_coord =  cell2mat(cellfun(@(x) size(x, 1), obs_array, 'uni', false));

    end
end
