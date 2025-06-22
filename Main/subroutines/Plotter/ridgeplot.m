function ridgeplot(AnParam,Posterior, gtarray,jj,Prior_forward)
% RIDGEPLOT Creates ridge line plots (joyplots) showing parameter distributions across stages
%
% Inputs:
%   AnParam: Analysis structure with parameters
%   Posterior: Cell array of posterior distributions from stage 1 to current stage jj 
%   gtarray: Ground truth values for parameters
%   jj: Current stage number
%   Prior_forward: Prior forward structure
%

%% Check if plotting is enabled
if AnParam.Switch_ridge == "off"
    return;
end

%% Setup and sample extraction
N_sample = 5000;  % Number of samples to plot for each stage
n_params = AnParam.N_parameters;

% Initialize samples cell array with prior samples
PriorOpts_EoD = datainput(Prior_forward);
myInput = uq_createInput(PriorOpts_EoD);
samples = cell( 1,jj+1);
samples{1,1} = uq_getSample(myInput, N_sample, 'LHS');

% Extract posterior samples for each stage
for ll = 1:jj
    all_samples = cell2mat({Posterior{1,ll}(:).samples});
    idx = randperm(size(all_samples, 1), N_sample);  % Randomly select N_sample rows
    samples{1,ll+1} = all_samples(idx, :);
end

% Reorganize samples by parameter (N_samples × N_stages for each parameter)
param_samples = cell( 1,n_params);
for nn = 1:n_params
    matrix_data = cell2mat(cellfun(@(x) x(:, nn), samples, 'UniformOutput', false));
    param_samples{1, nn} = num2cell(matrix_data', 2)';  
end

%% Create output directory if needed
output_folder = fullfile(pwd(), 'savedResults', 'ridgeplot');
if ~isfolder(output_folder)
    mkdir(output_folder);
end

% save the samples only once for the covariance paper
save  param_samples param_samples;


%% Generate plots for each parameter
for ii = 1:n_params
    fig = figure('visible', 'off');
    
    % Prepare data for current parameter
    current_data = param_samples{1,ii};
    
    % calcualte the sep length and Create ridge plot
    % uses dont need to know how Sep_value is calculated
    P_list = [];
    for uu = 1: numel(current_data)
        [p, x] = ksdensity(current_data{1,uu});
        P_list = [P_list,max(p)];
    end
	Sep_value = mean(P_list);
    %Sep_value = 0.3;

    hold on; 
    JP=joyPlot(current_data,'ColorMode','Kdensity','Sep',Sep_value,'MedLine','on','QtLine','on');
    JP=JP.draw();
    colorbar()



    
    % Add ground truth line if available
    if isnumeric(gtarray) 
        xline(gtarray(ii), '--r', 'LineWidth', 1.5);
    end
    
    hold off;
    
    % Save figure
    filename = sprintf('Stage%d_Param%d_%s', jj, ii, AnParam.figsExport);
    filepath = fullfile(output_folder, filename);
    exportgraphics(fig, filepath, 'BackgroundColor', 'white', 'Resolution', 300);
    
    close(fig);  % Close figure to free memory
end
end