function Boxplot(varargin)
% BOXPLOT Generate box plots for scalar FE outputs with Nature-style aesthetics
%
% Creates prior or posterior predictive box plots for scalar quantities of interest
% using clean, publication-quality formatting inspired by Nature journal style.
%
% Inputs:
%   Case 1 (Prior predictive): 
%       {FE_data, field_num, obs_stagetime}
%   Case 2 (Posterior predictive): 
%       {FE_data, field_num, obs_stagetime, jj}
%
% Parameters:
%   FE_data       - Prediction results matrix (samples × stages)
%   field_num     - Index of output field being plotted
%   jj            - Current stage index (for posterior case only)
%   obs_stagetime - Vector of stage time points


%% Input Processing
num_args = numel(varargin);
if num_args == 3; casename = 'priorPredive';else casename = 'postPredictive'; end

% Extract common parameters
FE_data = varargin{1};
field_num = varargin{2};
obs_stagetime = varargin{3};

%--- Nature-style color setup ---
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

colors.grey = [0.4 0.4 0.4];
colors.blue = [0.00, 0.45, 0.74];
colors.red = [0.85, 0.33, 0.10];
colors.lightgrey = [0.8 0.8 0.8];

% Create base plot
plot(obs_stagetime, FE_data, '-', 'Color', colors.lightgrey, 'LineWidth', 0.3);
set(gca, 'Children', flipud(get(gca, 'Children')));
xlabel('Displacement, $v_{G}$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Force, $H$ (kN)', 'Interpreter', 'latex', 'FontSize', 14);
set(gca, 'FontSize', 13, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);
xtickangle(0); ytickangle(0);box on;

%% Handle case-specific formatting
switch casename
    case 'priorPredive'  %Prior predictive case      
        title_name = sprintf('Piror predictive for $\\mathcal{G}_{%d}$', field_num);
        %title(title_name,'Interpreter', 'latex', 'FontSize', 14); 

    case 'postPredictive' % Posterior predictive case
        jj = varargin{end};%Gather out the current-stage time
        title_name = sprintf('Posterior predictive for $\\mathcal{G}_{%d}$', field_num);
        %title(title_name,'Interpreter', 'latex', 'FontSize', 14); 
        xline(obs_stagetime(jj), '--', 'LineWidth', 2, 'Color', colors.red);% draw a line at current stage 
 	
end





