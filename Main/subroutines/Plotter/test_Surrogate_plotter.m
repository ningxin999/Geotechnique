function test_Surrogate_plotter(AnParam,N_test,  YPCE, FEoutput, kk, jj)  
%  Plot surrogate test error (predictions vs actual)
%
% Inputs:
%   AnParam   - Analysis parameters structure (must contain figsExport field)
%   N_test    - Number of test samples (must be > 0)
%   YPCE      - Surrogate model predictions
%   FEoutput  - Original finite element output data
%   kk        - Output field index (positive integer)
%   jj        - Stage number (positive integer)

%tell whether validation set exist
assert(N_test > 0, 'N_test must be positive');

%plotting Yval vs YPCE 
Y_test = FEoutput{kk}{:,jj}(end - N_test +1:end,:);
Y_pred = YPCE;metrics = mean(calculate_GNAE_range(Y_pred,Y_test));
close all;fig = figure('visible','off');
plotregression(Y_test, Y_pred,'Test error');
ax = gca; % Get current axis
title(sprintf('GNAE = %.2f%%', metrics));
hold on;

% 🎨 Beautify labels
xlabel('True Values $T$', 'FontSize', 16, 'FontWeight', 'bold', ...
    'Color', 'k', 'Interpreter', 'latex');
ylabel('Predicted Values $Y$', 'FontSize', 16, 'FontWeight', 'bold', ...
    'Color', 'k', 'Interpreter', 'latex');

% 🎨 Enhance plot aesthetics
set(ax, 'FontSize', 14, 'LineWidth', 1.0, 'Box', 'on'); % Improve axis
set(findall(ax, 'Type', 'Line'), 'LineWidth', 1.0); % Make lines bolder
set(findall(ax, 'Type', 'Text'), 'FontSize', 14, 'FontWeight', 'normal', 'FontName', 'Times New Roman'); % Improve text clarity
grid on; % Enable grid
ax.YAxis.Exponent = -3;
colormap(turbo); % Use a modern colormap
hold off;  

%export the figs
% get the full path to create a 'savedResults' folder         
outputfolder = fullfile(pwd(),'trained_surrogate','Test_error'); 
if isfolder(outputfolder) == 0
    mkdir(outputfolder);
end

%Name and export figures 
filename = ['Stage' num2str(jj)  'Outputfield' num2str(kk) AnParam.figsExport ];
filepath  = fullfile(outputfolder,filename);
exportgraphics(fig,filepath,...
           'BackgroundColor','white','Resolution',300);
end

function GNAE_range_pct = calculate_GNAE_range(Y_true, Y_pred)
    % Computes the Global Normalized Absolute Error (range-normalized version)
    % 
    % Inputs:
    %   Y_true: Array of true/observed values (1×N or N×1)
    %   Y_pred: Array of predicted values (1×N or N×1, same size as Y_true)
    %
    % Output:
    %   GNAE_range_pct: Range-normalized MAE expressed as percentage
    %                  Formula: mean(|Y_true - Y_pred|) / (max(Y_true)-min(Y_true)) × 100%
    %
    % Features:
    %   - Avoids pointwise percentage issues (unlike MAPE)
    %   - Robust to data scale variations
    %   - Returns 0 for perfect prediction, >0 otherwise
    
    % Calculate Mean Absolute Error (MAE)
    MAE = mean(abs(Y_true - Y_pred));
    
    % Compute data range (avoids division-by-zero if all values are equal)
    range_Y = max(Y_true) - min(Y_true);
    if range_Y == 0
        range_Y = eps; % Use machine epsilon to prevent NaN
    end
    
    % Normalize MAE by data range and convert to percentage
    GNAE_range_pct = (MAE / range_Y) * 100; 
end