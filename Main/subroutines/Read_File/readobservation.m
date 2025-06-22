function [obs_coord, obs_array, gtarray, Noise, obs_stageTime] = readobservation(Noise, AnParam)
% READOBSERVATION: Reads observation data, ground truth (if available), and adds noise.
%
% Inputs:
%   - Noise:    Structure specifying noise properties.
%   - AnParam:  Structure containing analysis parameters.
%
% Outputs:
%   - obs_coord:     Cell array of observation coordinates.
%   - obs_array:     Processed observation data with noise applied.
%   - gtarray:       Ground truth data (if exists, otherwise 'null').
%   - Noise:         Updated Noise structure.
%   - obs_stageTime: Array of observation stage times.

    %% Step 1: Read Observation Data
    directory = AnParam.directory;

    evalc('[obs_cell,obs_stageTime]   =  readmycsv(directory.inputcsv,true,true);');

    
    N_obs = numel(obs_cell);  % Number of observations
    obs_coord = cell(1, N_obs);
    obs_array = cell(1, N_obs);
    
    for ii = 1:N_obs
        % Extract coordinates (first column) and observation values (remaining columns)
        obs_coord{ii} = unique(obs_cell{ii}(:,1)', 'stable');  
        obs_array{ii} = obs_cell{ii}(:,2:end);
    end

    %% Step 2: Read Ground Truth (if available)
    GT_path = fullfile(directory.inputcsv, 'GroundTruth.csv');
    if isfile(GT_path)
        GTtable = readtable(GT_path,ReadRowNames=true);
        gtarray = table2array(GTtable)'; 
    else
        warning('GroundTruth.csv not found in directory: %s', directory.inputcsv);
        gtarray = 'null';
    end

    %% Step 3: Apply Noise to Observations
    for jj = 1:N_obs
        noise_std = Noise.scalar * obs_array{jj}; % Compute element-wise noise standard deviation
        Noise.vector{jj} = normrnd(0, 1, size(obs_array{jj},1), 1); % Generate a noise matrix with standard normal distribution
        Noise.matrix{jj} = Noise.vector{jj} .* noise_std;% Scale the noise matrix element-wise
        obs_array{jj} = obs_array{jj} + Noise.matrix{jj};% Add noise to the observations
    end
end

